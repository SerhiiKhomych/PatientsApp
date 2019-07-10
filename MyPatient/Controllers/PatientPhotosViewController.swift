//
//  PatientPhotosCollectionViewController.swift
//  MyPatient
//
//  Created by Serhii Khomych on 08.07.19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PatientPhotosViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var chooseCancelButton: UIBarButtonItem!
    
    var images:[UIImage] = [UIImage]()
    var directoryName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.title = directoryName
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURL = documentsDirectory.appendingPathComponent(directoryName)

        guard let fileEnumerator = FileManager.default.enumerator(at: fullURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions()) else { return }
        images.removeAll()
        while let file = fileEnumerator.nextObject() {
            images.append(UIImage(contentsOfFile: (file as! URL).path)!)
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 5, y: 5, width: cell.frame.width, height: cell.frame.height));
        imageView.image = images[indexPath.row]
        cell.contentView.addSubview(imageView)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.allowsMultipleSelection == false {
            performSegue(withIdentifier: "fullscreenPhotoSegue", sender: indexPath)
        } else {
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.contentView.alpha = 0.5
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.alpha = 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.8, height: collectionView.frame.height * 0.6)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fullscreenPhotoSegue" {
            let indexPath = sender as! IndexPath
            let fullscreenPhotoVC = segue.destination as! FullscreenPhotoViewController
            fullscreenPhotoVC.image = images[indexPath.row]
            collectionView.deselectItem(at: indexPath, animated: true)
        } 
    }
    
    @IBAction func choose(_ sender: Any) {
        if collectionView.allowsMultipleSelection == false {
            chooseCancelButton.title = "Cancel"
            collectionView.allowsMultipleSelection = true
        } else {
            chooseCancelButton.title = "Choose"
            collectionView.allowsMultipleSelection = false
            
            let cells = collectionView.visibleCells
            for cell in cells {
                cell.contentView.alpha = 1
            }
        }
    }
}
