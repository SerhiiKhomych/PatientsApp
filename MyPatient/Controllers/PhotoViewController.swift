//
//  PhotoViewController.swift
//  MyPatient
//
//  Created by Serhii Khomych on 05.07.19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    var takenPhoto: UIImage!
    var patient: Patient!

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let availableImage = takenPhoto {
            imageView.contentMode = .scaleToFill
            imageView.image = availableImage
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        let fileManager = FileManager.default

        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryName = patient.firstName + " " + patient.surname
        let fullURL = documentsDirectory.appendingPathComponent(directoryName)
        
        var isDir : ObjCBool = true
        if !fileManager.fileExists(atPath: fullURL.path, isDirectory:&isDir) {
            do {
                try fileManager.createDirectory(at: fullURL, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
        
        if let availableImage = takenPhoto {
            if let data = availableImage.jpegData(compressionQuality: 1.0) {
                do {
                    try data.write(to: fullURL.appendingPathComponent(Util.getTodayString(includeTime: true)))
                } catch let error as NSError {
                    NSLog("Unable to save file \(error.debugDescription)")
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}
