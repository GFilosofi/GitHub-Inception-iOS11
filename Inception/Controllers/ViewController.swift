//
//  ViewController.swift
//  Inception
//
//  Created by Gabriele Filosofi on 25/03/2018.
//  Copyright © 2018 Gabriele Filosofi. All rights reserved.
//

import UIKit
import CoreML
import Vision
import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var inputImage: UIImageView!
    @IBOutlet weak var observIdLabel: UILabel!
    @IBOutlet weak var observScoreLabel: UILabel!
    
    lazy var imgPicker: UIImagePickerController = {
       let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        navigationController?.navigationBar.tintColor = UIColor.orange
        navigationController?.navigationBar.isTranslucent = false
        observScoreLabel.isHidden = true
        observIdLabel.isHidden = true
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        observScoreLabel.isHidden = true
        observIdLabel.isHidden = true
        SVProgressHUD.show()
        var uiimage = UIImage()
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            uiimage = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            uiimage = originalImage
        }
        inputImage.image = uiimage
        dismiss(animated: true, completion: nil)

        if let ciimage = CIImage(image: uiimage) {
            classify(image: ciimage)
        }
    }
    
    func classify(image: CIImage) {
        guard let selectedModel = try? VNCoreMLModel(for: Inceptionv3().model) else { fatalError("Cannot load the CoreML model") }
        
        let request = VNCoreMLRequest(model: selectedModel) { (request, error) in
            if error != nil {
                print("Error: \(String(describing: error))")
            }
            guard let results = request.results as? [VNClassificationObservation] else { fatalError("Cannot get results from CoreML model") }
            if let firstResult = results.first {
                DispatchQueue.main.async(execute: {() -> Void in
                    self.observIdLabel.text = firstResult.identifier
                    self.observScoreLabel.text = String(firstResult.confidence)
                    self.observScoreLabel.isHidden = false
                    self.observIdLabel.isHidden = false
                })
            }
        }
        
        //input the test image to the image analysis request
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        SVProgressHUD.dismiss()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func photoLibraryButton(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imgPicker.sourceType = .savedPhotosAlbum
            present(imgPicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imgPicker.sourceType = .camera
            present(imgPicker, animated: true, completion: nil)
        }
    }
}

