//
//  PatientViewController.swift
//  MyPatient
//
//  Created by Serhii Khomych on 04.07.19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class PatientViewController: UIViewController {

    @IBOutlet weak var patientName: UITextField!
    @IBOutlet weak var patientSurname: UITextField!
    @IBOutlet weak var diagnosys: UITextField!
    
    var barController: MainTabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barController = self.tabBarController as? MainTabBarController
    }
    
    @IBAction func patientNameEndInput(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func patientNameListener(_ sender: UITextField) {
        if let controller = barController {
            controller.patient.firstName = sender.text
        }
    }
    
    @IBAction func patientSurnameEndInput(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func patientSurnameListener(_ sender: UITextField) {
        if let controller = barController {
            controller.patient.surname = sender.text
        }
    }
    
    @IBAction func diagnosysEndInput(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func diagnosysListener(_ sender: UITextField) {
        if let controller = barController {
            controller.patient.diagnosys = sender.text
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
