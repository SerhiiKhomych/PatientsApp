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
    var imagesURL:[UIImage:URL] = [:]

    var directoryName: String!
    
    var defaultBackButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        defaultBackButton = self.navigationItem.leftBarButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.title = directoryName
        
        let fileManager = FileManager.default
        
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURL = documentsDirectory.appendingPathComponent(directoryName)

        guard let fileEnumerator = fileManager.enumerator(at: fullURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions()) else { return }
        images.removeAll()
        imagesURL.removeAll()
        while let file = fileEnumerator.nextObject() {
            let image = UIImage(contentsOfFile: (file as! URL).path)!
            images.append(image)
            imagesURL.updateValue(file as! URL, forKey: image)
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
            toDeleteMode()
        } else {
            toChooseItemsMode()
        }
    }
    
    @objc func trash(sender: UIBarButtonItem) {
        if let indexPaths = collectionView.indexPathsForSelectedItems {
            for indexPath in indexPaths.reversed() {
                do {
                    let fullURL = imagesURL[images[indexPath.row]]!
                    try FileManager.default.removeItem(atPath: fullURL.path)
                } catch {
                    print("Could not remove image: \(error)")
                }
               imagesURL.removeValue(forKey: images[indexPath.row])
               images.remove(at: indexPath.row)
            }
            
            collectionView.deleteItems(at: indexPaths)
        }
        toChooseItemsMode()
    }
    
    func toChooseItemsMode() {
        chooseCancelButton.title = "Choose"
        collectionView.allowsMultipleSelection = false
        
        self.navigationItem.leftBarButtonItem = defaultBackButton
        
        let cells = collectionView.visibleCells
        for cell in cells {
            cell.contentView.alpha = 1
        }
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = false
    }
    
    func toDeleteMode() {
        chooseCancelButton.title = "Cancel"
        collectionView.allowsMultipleSelection = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(PatientPhotosViewController.trash(sender:)))
    }
}
