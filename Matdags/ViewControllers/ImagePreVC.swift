//  CameraImgPreVC.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-10-10.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import AVFoundation
import Firebase

class ImagePreVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var vegFood: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var descriptionFieldLines: UITextView!
    
    var vegFoodBool : Bool = false
    var commentBool : Bool = false
    var hiddenTextfield = true
    
    var image: UIImage!
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image
        
//        descriptionField.delegate = self
//        descriptionField.setLeftPaddingPoints(20)
//        descriptionField.setRightPaddingPoints(20)

        descriptionFieldLines.delegate = self

    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
//        descriptionField.isHidden = true
//        if descriptionField.text == "" {
//            commentBtn.setImage(UIImage(named: "commentButton50"), for: .normal)
//        }else{
//
//        }
        
        descriptionFieldLines.isHidden = true
        if descriptionFieldLines.text == "" {
            commentBtn.setImage(UIImage(named: "commentButton50"), for: .normal)
        }else{
            
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
//        descriptionField.isHidden = true
//        if descriptionField.text == "" {
//            commentBtn.setImage(UIImage(named: "commentButton50"), for: .normal)
//        }else{
//
//        }
        
        descriptionFieldLines.isHidden = true
        if descriptionFieldLines.text == "" {
            commentBtn.setImage(UIImage(named: "commentButton50"), for: .normal)
        }else{
            
        }
            return true
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let text = textField.text!
//        let maxLength = text.count + string.count - range.length
//        return maxLength <= 10
//    }
    
    @IBAction func postButton(_ sender: Any) {
        UploadImageToFirebase(in: dispatchGroup)
    }
    
    @IBAction func saveLocalButton(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("\n Image saved to local library. \n")
        let alert = UIAlertController(title: "Hurra!", message: "Bilden sparades på din telefon!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func vegFoodAction(_ sender: UIButton) {
        if vegFoodBool  == false {
            vegFood.setImage(UIImage(named: "vegButton100.png"), for: .normal)
            vegFoodBool = true
        }else{
            vegFood.setImage(UIImage(named: "vegButton100off.png"), for: .normal)
            vegFoodBool = false
        }
    }
    
    @IBAction func commentClick(_ sender: UIButton) {
        commentBtn.setImage(UIImage(named: "commentButton50orange"), for: .normal)
//        descriptionField.isHidden = false
//        descriptionField.becomeFirstResponder()
        
        descriptionFieldLines.isHidden = false
        descriptionFieldLines.becomeFirstResponder()
    }
    
    func UploadImageToFirebase(in dispatchGroup: DispatchGroup) {
        AppDelegate.instance().showActivityIndicator()
        let uid = Auth.auth().currentUser?.uid
        let database = Database.database().reference(withPath: "Posts")
        let usrdatabase = Database.database().reference(withPath: "Users")
        let storage = Storage.storage().reference().child("images").child(uid!)
        let key = database.childByAutoId().key
        let imageRef = storage.child("\(key)")
        let imageRef256 = storage.child("\(key)256")
        let resizedImage = AppDelegate.instance().resizeImage(image: self.image!, targetSize: CGSize.init(width: 256, height: 256))
        let fullImage = AppDelegate.instance().resizeImage(image: self.image!, targetSize: CGSize.init(width: 1024, height: 1024))
        
        //Datum
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        let result = formatter.string(from: date)
        
        let postfeed = ["userID" : uid!,
                    "date": result,
                    "rating" : 0,
                    "alias" : Auth.auth().currentUser!.displayName!,
                    "imgdescription" : self.descriptionFieldLines.text!,
                    "postID" : key,
                    "usersRated" : 0] as [String : Any]
        let postIdExtra = ["postID" : key] as [String : Any]
        database.child("\(key)").updateChildValues(postfeed)
        database.child("\(key)").updateChildValues(["vegetarian" : vegFoodBool])
        
        usrdatabase.child("\(uid!)").child("Posts").updateChildValues(["\(key)" : key])
        usrdatabase.child("\(uid!)").child("Posts").child("\(key)").updateChildValues(["vegetarian" : vegFoodBool])
        
        //Bild i full storlek
        if let imageData = UIImageJPEGRepresentation(fullImage, 0.8) {
            dispatchGroup.enter()
            let uploadTask = imageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                    print(error!)
                    return
                }
                let firstURL = metadata?.downloadURL()?.absoluteString
                if firstURL != nil {
                    let postURL = ["pathToImage" : firstURL!]
                    database.child("\(key)").updateChildValues(postURL)
                    usrdatabase.child("\(uid!)").child("Posts").child("\(key)").updateChildValues(postURL) // NY TEST DANIEL
                    usrdatabase.child("\(uid!)").child("Posts").child("\(key)").updateChildValues(postIdExtra) // NY TEST DANIEL
                    print("\n Image uploaded! \n")
                } else {
                    print("\n Could not allocate URL for full size image. \n")
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                }
                dispatchGroup.leave()
            })
            uploadTask.resume()
        }
        
        if let imageData256 = UIImageJPEGRepresentation(resizedImage, 0.8) {
            dispatchGroup.enter()
            let uploadTask256 = imageRef256.putData(imageData256, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                    print(error!)
                    return
                }
                let secondURL = metadata?.downloadURL()?.absoluteString
                if secondURL != nil {
                    let postURL = ["pathToImage256" : secondURL!] as [String : Any]
                    database.child("\(key)").updateChildValues(postURL)
                    usrdatabase.child("\(uid!)").child("Posts").child("\(key)").updateChildValues(postURL) // NY TEST DANIEL
                    print("\n Thumbnail uploaded! \n")
                } else {
                    print("\n Could not allocate URL for resized image. \n")
                    dispatchGroup.leave()
                    AppDelegate.instance().dismissActivityIndicator()
                }
                dispatchGroup.leave()
                dispatchGroup.notify(queue: .main, execute: {
                    print("\n Async completed \n")
                    AppDelegate.instance().dismissActivityIndicator()
                    self.dismiss(animated: false, completion: nil)
                })
            })
            uploadTask256.resume()
        }
    }
}

