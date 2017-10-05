//
//  CameraVC.swift
//  Matdags
//
//  Created by Kevin Henriksson on 2017-10-05.
//  Copyright © 2017 Matdags. All rights reserved.
//

import UIKit

class CameraVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
}
