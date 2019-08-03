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
    
    var barController: MainTabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barController = self.tabBarController as? MainTabBarController
        
        barController.tabBar.tintColor = UIColor.red
        
        patientName.text = ""
        patientName.layer.borderWidth = 1
        patientName.layer.borderColor = UIColor.red.cgColor
    }
    
    @IBAction func patientNameEndInput(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func patientNameListener(_ sender: UITextField) {
        barController.patient.fullName = sender.text
        if patientName.text != "" {
            patientName.layer.borderWidth = 0
        } else {
            barController.patient.fullName = nil
        }
        if !barController.isPatientEmpty() {
            barController.tabBar.tintColor = UIColor.gray
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        barController = self.tabBarController as? MainTabBarController
        
        barController.tabBar.tintColor = UIColor.red
        
        barController.patient.fullName = nil
        patientName.text = ""
        patientName.layer.borderWidth = 1
        patientName.layer.borderColor = UIColor.red.cgColor
    }
}
