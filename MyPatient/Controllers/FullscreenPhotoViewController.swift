//
//  FullscreenPhotoViewController.swift
//  MyPatients
//
//  Created by Serhii Khomych on 09.07.19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class FullscreenPhotoViewController: UIViewController, UIScrollViewDelegate {
    
    var image: UIImage?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        if let availableImage = image {
            imageView.contentMode = .scaleToFill
            imageView.image = availableImage
        }
    
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
