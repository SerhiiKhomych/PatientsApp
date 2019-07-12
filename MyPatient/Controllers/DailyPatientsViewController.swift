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
        let googleDriveApiService = GoogleDriveApiService()
        
        if let indexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                let directoryName = items[indexPath.row]
                var folderIdentifier: String?
                
                googleDriveApiService.getFolderID(name: directoryName, service: googleDriveService,user: googleUser) {
                    folderIdentifier = $0
                    
                    let fileManager = FileManager.default
                    
                    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fullURL = documentsDirectory.appendingPathComponent(directoryName)
                    
                    guard let fileEnumerator = fileManager.enumerator(at: fullURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions()) else { return }
                    
                    if let folderId = folderIdentifier {
                        while let file = fileEnumerator.nextObject() {
                            let fileURL = file as! URL
                            googleDriveApiService.uploadFile(name: fileURL.lastPathComponent, folderID: folderId, fileURL: fileURL, mimeType: "image/jpeg", service: self.googleDriveService)
                        }
                    } else {
                        googleDriveApiService.createFolder(name: directoryName, service: self.googleDriveService) {
                            while let file = fileEnumerator.nextObject() {
                                let fileURL = file as! URL
                                googleDriveApiService.uploadFile(name: fileURL.lastPathComponent, folderID: $0, fileURL: fileURL, mimeType: "image/jpeg", service: self.googleDriveService)
                            }
                        }
                    }
               }
                editCancel.title = "Choose"
                cloud.isEnabled = false
                
                tableView.allowsMultipleSelectionDuringEditing = false
                tableView.setEditing(false, animated: false)
            }
        }
    }
}
