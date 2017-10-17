//  CameraImgPreVC.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-10-10.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import AVFoundation

class CameraImgPreVC: UIViewController{
    
    @IBOutlet weak var photo: UIImageView!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photo.image = self.image
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
    }
    
}