//  RegisterViewController.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-09-14.
//  Copyright © 2017 Nicklas Gilbertson. All rights reserved.

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class RegisterVC: UIViewController {


    @IBOutlet var mail: UITextField!
    
    @IBOutlet var password: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    

    @IBAction func Register(_ sender: Any) {
        Auth.auth().createUser(withEmail: mail.text!, password: password.text!, completion: {
            user, error in
            
            if error != nil {
                self.login()
            }
            else {
                
                print ("User created")
                self.login()
            }
        })
    }

    func login(){
        Auth.auth().signIn(withEmail: mail.text!, password: password.text!, completion: {
            user, error in
            
            if error != nil{
                
                print ("Incorrect")
            }
            else{
                self.goHome()
                print("Correct")
            }
        })
    }
    
    func goHome() {
        let homePage = ImageFeedVC()
        self.present(homePage, animated: true,
                     completion: nil)
    }
}