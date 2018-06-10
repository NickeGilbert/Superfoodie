//
//  reportUser.swift
//  Matdags
//
//  Created by Nicklas Gilbertson on 2018-05-25.
//  Copyright © 2018 Matdags. All rights reserved.
//

import UIKit
import Firebase

extension ImagePageVC {
    
    func reportPost() {
        if reports <= 5 {
            let userPostId = self.posts[0]
            let ref = Database.database().reference().child("Posts").child(seguePostID)
            if self.posts[0] != nil {
                //let userRepots = ["Reports" : "\(reports)" ] as [String : Any]
                
                reports = reports+1
                let myReports = ["Reports" : reports ] as [String : Int]
                ref.updateChildValues(myReports)
            } else {
                print("Did not work")
            }
        } else {
            self.deletePosts()
        }
    }
    
    func reportPostSecond() {
        if reports <= 5 {
            let userPostUID = self.posts[0].userID
            print("Användarens post id: ", userPostUID)
            let ref = Database.database().reference().child("Users").child(userPostUID!).child("Posts").child(seguePostID)
            print("DATABASEN ÄR: ", ref)
            if self.posts[0] != nil {
                
                reports = reports+1
                let myReports = ["Reports" : reports ] as [String : Int]
                ref.updateChildValues(myReports)
            } else {
                print("Did not work")
            }
        } else {
            let userPostUID = self.posts[0].userID
            let myRef = Database.database().reference().child("Users").child(userPostUID!).child("Posts").child(seguePostID)
            myRef.removeValue { (error, ref) in
                if error != nil {
                    print("DIDN'T GO THROUGH")
                    return
                }
                print("POST DELETED")
            }
        }
    }
    
    func checkHowManyReportsPostHave() {
        let ref = Database.database().reference()
        ref.child("Posts").child(seguePostID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            let value = snapshot.value as? NSDictionary
            self.reports = value?["Reports"] as? Int ?? -1
            print("THE USER THAT I HAVE CLICKED ON HAVE ", self.reports ,"ON THIS POST")
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    
//    func reportUserPost() {
//        if countReports == maxReports {
//            let ref = Database.database().reference().child("Posts").child(seguePostID)
//            ref.removeValue { (error, ref) in
//                if error != nil {
//                    print("DIDN'T GO THROUGH")
//                    return
//                }
//                self.dismiss(animated: true, completion: nil)
//                print("POST DELETED")
//            }
//
//            //I denna funktionen måste uid bytas ut. Det ska vara användarens uid och inte mitt egna.
//            let myRef = Database.database().reference().child("Users").child(uid).child("Posts").child(seguePostID)
//            myRef.removeValue { (error, ref) in
//                if error != nil {
//                    print("DIDN'T GO THROUGH")
//                    return
//                }
//                print("POST DELETED")
//            }
//        }
//    }
}