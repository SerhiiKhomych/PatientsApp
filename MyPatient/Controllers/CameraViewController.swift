//
//  CameraViewController.swift
//  MyPatient
//
//  Created by Serhii Khomych on 04.07.19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var previewView: UIView!
    
    var barController: MainTabBarController?
    
    let captureSession: AVCaptureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice!
    
    var takePhoto = false
    
    var patient: Patient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barController = self.tabBarController as? MainTabBarController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // initialise session preset. It enables quality of camera
        // todo: change preset
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        
        if availableDevices.count > 0 {
            captureDevice = availableDevices.first;
            
            // set input data to the captureSession
            do {
                let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(captureDeviceInput)
            } catch let error as NSError {
                NSLog("Failed to set device input: %@", error)
            }
            
            // set previewLayer as a sublayer of the view
            // todo: fix this logic
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            view.layer.addSublayer(previewLayer)
            previewLayer.frame = view.layer.frame
            
            // run captureSession
            captureSession.startRunning()
            
            // set output data to the captureSession
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            
            // commit captureSession
            captureSession.commitConfiguration()
            
            // add queue to the output data
            let queue = DispatchQueue(label: "photoQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let controller = barController {
            patient = controller.patient
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCaptureSession()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if takePhoto {
            takePhoto = false
            
            if let image = getImageFromSampleBuffer(buffer: sampleBuffer) {
                let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoVC") as! PhotoViewController
            
                photoVC.takenPhoto = image
                photoVC.patient = patient
                
                DispatchQueue.main.async {
                    self.present(photoVC, animated: true, completion: {
                        self.stopCaptureSession()
                    })
                }
            }
        }
    }
    
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    func stopCaptureSession() {
        captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchPoint = touches.first {
            let screenSize = view.bounds.size
            let focusPoint = CGPoint(x: touchPoint.location(in: view).y / screenSize.height, y: 1.0 - touchPoint.location(in: view).x / screenSize.width)
            
            if let device = captureDevice {
                do {
                    try device.lockForConfiguration()
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                } catch let error as NSError {
                    NSLog("Could not lock device for configuration: %@", error)
                }
            }
        }
    }
    
    @IBAction func changeZoom(_ sender: UISlider) {
        if let availableDevice = captureDevice {
            let device = availableDevice
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = CGFloat(sender.value)
                device.unlockForConfiguration()
            } catch let error as NSError {
                NSLog("Could not lock device for configuration: %@", error)
            }
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        takePhoto = true
    }
}
