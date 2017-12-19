//  ViewController.swift
//  Matdags
//  Created by Kevin Henriksson on 2017-09-21.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet var emailText: UITextField!
    @IBOutlet var password: UITextField!
    var FBdata : Any?
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailText.delegate = self
        password.delegate = self
        
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 65, y: 400, width: view.frame.width - 130, height: 50)
        loginButton.delegate = self
        
        if FBSDKAccessToken.current() != nil {
            fetchProfile()
        }
        
        if(Auth.auth().currentUser != nil && Auth.auth().currentUser?.isEmailVerified == true) {
            self.performSegue(withIdentifier: "HomeToFeed", sender: AnyObject.self)
        }

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func fetchProfile() {
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) -> Void in
            if error != nil {
                print("\n \(error!) \n")
                return
            }
            self.FBdata = result
            let request = FBSDKGraphRequest(graphPath:"me", parameters:nil)
            
            request!.start { (connection, result, error) in
                if error != nil {
                    print("\n \(error!) \n")
                } else if let userData = result as? [String:AnyObject] {
                    let username = userData["name"] as? String
                    print(username!)
                }
            }
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        AppDelegate.instance().showActivityIndicator()
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("\n \(error!) \n")
                self.createAlertLogin(title: "Problem", message: "Något inloggningsproblem uppstod, vänligen försök igen")
                return
            } else {
                self.performSegue(withIdentifier: "HomeToFeed", sender: AnyObject.self)
                self.fetchProfile()
                self.createFirebaseUser()
                print("\n INLOGGAD MED FACEBOOK \n ")
                AppDelegate.instance().dismissActivityIndicator()
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("LOGOUT BUTTON FACEBOOK")
    }
    
    @IBAction func loginButton(_ sender: Any) {
        login()
        password.resignFirstResponder()
    }
    
    func login(){
        AppDelegate.instance().showActivityIndicator()
        
        Auth.auth().signIn(withEmail: emailText.text!, password: password.text!, completion: { user, error in
            
            if error != nil{
                // ERROR INLOGGNING
                self.createAlertLogin(title: "Error", message: "Något blev fel. Försök igen!")
                print("\n \(error!) \n")
                self.createAlertLogin(title: "Problem", message: "Något inloggningsproblem uppstod, vänligen försök igen")
                AppDelegate.instance().dismissActivityIndicator()
            } else {
                if(Auth.auth().currentUser?.isEmailVerified == true)
                {
                    //Där finns en print i createFireBaseUser som händer om användaren loggar in med mail första gången.
                    self.createFirebaseUser()
                    self.performSegue(withIdentifier: "HomeToFeed", sender: AnyObject.self)
                } else {
                    self.createAlertLogin(title: "Verifiering", message: "Vänligen godkänn ditt konto i din mail")
                    AppDelegate.instance().dismissActivityIndicator()
                }
            }
        })
    }
    
    func createFirebaseUser() {
        let uid = Auth.auth().currentUser!.uid
        let username = Auth.auth().currentUser!.displayName
        let useremail = Auth.auth().currentUser!.email
        //let profilePictureURL = NSString(string: "http://graph.facebook.com/"+FBSDKAccessToken.current().userID+"/picture?type=large")
        let profilePictureURL = ""
        let database = Database.database().reference(withPath: "Users/\(uid)")
        print("\n \(uid) \n")
        print("\n \(String(describing: username)) \n")
        print("\n \(String(describing: useremail)) \n")
        if useremail == nil || username == nil {
            return
        }
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let result = formatter.string(from: date)
        let feed = ["followingCounter" : 0,
                    "followerCounter" : 0,
                    "alias" : username!,
                    "date" : result,
                    "uid" : uid,
                    "profileImageURL" : "",
                    "email" : useremail!] as [String : Any]
        database.updateChildValues(feed)
        print("\n Firebase User Created! \n")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailText.isEditing == true {
            self.password.becomeFirstResponder()
            return true
        } else {
            self.view.endEditing(true)
            login()
            return true
        }
    }
    
    func createAlertLogin (title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{ action in
            alert.dismiss(animated: true, completion: nil)
            // Fler saker här för att köra mer kod
        }))
        //        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
        //            action in
        //            alert.dismiss(animated: true, completion: nil)      SKAPA UPP FLER AV DESSA FÖR FLERA VAL
        //        }))
        self.present(alert, animated: true, completion: nil)
    }
}

