//
//  DailtPatientsTableViewController.swift
//  MyPatient
//
//  Created by Serhii Khomych on 07.07.19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class DailyPatientsViewController: UITableViewController {

    @IBOutlet weak var cloud: UIBarButtonItem!
    @IBOutlet weak var editCancel: UIBarButtonItem!
    
    var items:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let fileManager = FileManager.default
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fullURL = documentsDirectory.appendingPathComponent(items[indexPath.row])
            do {
                try fileManager.removeItem(atPath: fullURL.path)
            } catch {
                print("Could not remove folder: \(error)")
            }
            
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
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
}
