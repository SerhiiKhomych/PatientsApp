//
//  Patient.swift
//  MyPatient
//
//  Created by Serhii Khomych on 06.07.19.
//  Copyright © 2019 Test. All rights reserved.
//

class Patient {
    var firstName: String!
    var surname: String!
    var diagnosys: String!
    
    init() {
    }
    
    init(firstName: String, surname: String, diagnosys: String) {
        self.firstName = firstName
        self.surname = surname
        self.diagnosys = diagnosys
    }
    
    init(firstName: String, surname: String) {
        self.firstName = firstName
        self.surname = surname
    }
}
