//
//  DailtPatientsTableViewController.swift
//  MyPatient
//
//  Created by Serhii Khomych on 07.07.19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class DailyPatientsViewController: UITableViewController {

    @IBOutlet weak var cloud: UIBarButtonItem!
    @IBOutlet weak var editCancel: UIBarButtonItem!
    
    var items:[String] = [String]()
    
    var googleDriveService: GTLRDriveService!
    var googleUser: GIDGoogleUser!
    
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    
    /// Text shown during load the TableView
    let loadingLabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        let barController = self.tabBarController as? MainTabBarController
        googleDriveService = barController?.googleDriveService
        googleUser = barController?.googleUser
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            items = try fileManager.contentsOfDirectory(atPath: documentsDirectory.path)
            tableView.reloadData()
        } catch let error as NSError {
            NSLog("Unable to get a content of a directory \(error.debugDescription)")
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)

        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            performSegue(withIdentifier: "patientPhotosSegue", sender: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fullURL = documentsDirectory.appendingPathComponent(items[indexPath.row])
            do {
                try fileManager.removeItem(atPath: fullURL.path)
            } catch {
                print("Could not remove folder: \(error)")
            }
            
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "patientPhotosSegue" {
            let indexPath = sender as! IndexPath
            let patientPhotosVC = segue.destination as! PatientPhotosViewController
            patientPhotosVC.directoryName = items[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func edit(_ sender: Any) {
        if !tableView.isEditing {
            editCancel.title = "Cancel"
            cloud.isEnabled = true
            
            tableView.allowsMultipleSelectionDuringEditing = true
            tableView.setEditing(true, animated: false)
        } else {
            editCancel.title = "Choose"
            cloud.isEnabled = false

            tableView.allowsMultipleSelectionDuringEditing = false
            tableView.setEditing(false, animated: false)
        }
    }
    
    @IBAction func sendToTheCloud(_ sender: Any) {
        setLoadingScreen()

        let googleDriveApiService = GoogleDriveApiService()
        let group = DispatchGroup()
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                group.enter()
                let directoryName = items[indexPath.row]
                let fileManager = FileManager.default
                
                let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fullURL = documentsDirectory.appendingPathComponent(directoryName)
                
                guard let fileEnumerator = fileManager.enumerator(at: fullURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions()) else { return }
                
                var fileURLs:[URL] = [URL]()
                while let file = fileEnumerator.nextObject() {
                    group.enter()
                    let fileURL = file as! URL
                    fileURLs.append(fileURL)
                }
                
                var folderIdentifier: String?
                googleDriveApiService.getFolderID(name: directoryName, service: googleDriveService,user: googleUser) {
                    folderIdentifier = $0
                    group.leave()
                    if let folderId = folderIdentifier {
                        for fileURL in fileURLs {
                            googleDriveApiService.uploadFile(name: fileURL.lastPathComponent, folderID: folderId, fileURL: fileURL, mimeType: "image/jpeg", service: self.googleDriveService) {_ in
                                group.leave()
                            }
                        }
                    } else {
                        group.enter()
                        googleDriveApiService.createFolder(name: directoryName, service: self.googleDriveService) {
                            group.leave()
                            for fileURL in fileURLs {
                                googleDriveApiService.uploadFile(name: fileURL.lastPathComponent, folderID: $0, fileURL: fileURL, mimeType: "image/jpeg", service: self.googleDriveService) {_ in
                                    group.leave()
                                }
                            }
                        }
                    }
                }
            }
            group.notify(queue:.main) {
                self.removeLoadingScreen()
                
                self.editCancel.title = "Choose"
                self.cloud.isEnabled = false
                
                self.tableView.allowsMultipleSelectionDuringEditing = false
                self.tableView.setEditing(false, animated: false)
            }
        }
    }
    
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (tableView.frame.width / 2) - (width / 2)
        let y = (tableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Sets loading text
        loadingLabel.isHidden = false
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        // Sets spinner
        spinner.isHidden = false
        spinner.style = .gray
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
        
        tableView.addSubview(loadingView)
        
    }
    
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        spinner.stopAnimating()
        spinner.isHidden = true
        loadingLabel.isHidden = true
        
    }
}
