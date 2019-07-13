//
//  Util.swift
//  MyPatients
//
//  Created by Serhii Khomych on 13.07.19.
//  Copyright © 2019 Test. All rights reserved.
//
import UIKit

class Util {
    
    static func getTodayString(includeTime: Bool) -> String {
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        
        let todayString: String = String(year!) + "-" + String(month!) + "-" + String(day!)
        
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let currentTime: String = String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        
        if includeTime {
            return todayString + " " + currentTime
        } else {
            return todayString
        }
    }
}
