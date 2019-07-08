//
//  PhotoViewController.swift
//  MyPatient
//
//  Created by Serhii Khomych on 05.07.19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    var takenPhoto: UIImage?
    var patient: Patient?

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let availableImage = takenPhoto {
            imageView.image = availableImage;
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryName = (patient?.firstName ?? "No_name") + " " + (patient?.surname ?? "No_surname")
        let fullURL = documentsDirectory.appendingPathComponent(directoryName)
        
        var isDir : ObjCBool = true
        if !FileManager.default.fileExists(atPath: fullURL.path, isDirectory:&isDir) {
            do {
                try FileManager.default.createDirectory(at: fullURL, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
        
        if let data = takenPhoto?.pngData() {
            do {
                try data.write(to: fullURL.appendingPathComponent(getTodayString()))
            } catch let error as NSError {
                NSLog("Unable to save file \(error.debugDescription)")
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func getTodayString() -> String{
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        
        return today_string
    }
}
