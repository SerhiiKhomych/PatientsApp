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
    
    var barController: MainTabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barController = self.tabBarController as? MainTabBarController
        
        barController.tabBar.tintColor = UIColor.red
        
        patientName.text = ""
        patientName.layer.borderWidth = 1
        patientName.layer.borderColor = UIColor.red.cgColor
        
        patientSurname.text = ""
        patientSurname.layer.borderWidth = 1
        patientSurname.layer.borderColor = UIColor.red.cgColor
    }
    
    @IBAction func patientNameEndInput(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func patientNameListener(_ sender: UITextField) {
        barController.patient.firstName = sender.text
        if patientName.text != "" {
            patientName.layer.borderWidth = 0
        } else {
            barController.patient.firstName = nil
        }
        if !barController.isPatientEmpty() {
            barController.tabBar.tintColor = UIColor.gray
        }
    }
    
    @IBAction func patientSurnameEndInput(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func patientSurnameListener(_ sender: UITextField) {
        barController.patient.surname = sender.text
        if patientSurname.text != "" {
            patientSurname.layer.borderWidth = 0
        } else {
            barController.patient.surname = nil
        }
        if !barController.isPatientEmpty() {
            barController.tabBar.tintColor = UIColor.gray
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        barController = self.tabBarController as? MainTabBarController
        
        barController.tabBar.tintColor = UIColor.red
        
        barController.patient.firstName = nil
        patientName.text = ""
        patientName.layer.borderWidth = 1
        patientName.layer.borderColor = UIColor.red.cgColor
        
        barController.patient.surname = nil
        patientSurname.text = ""
        patientSurname.layer.borderWidth = 1
        patientSurname.layer.borderColor = UIColor.red.cgColor
    }
}
