//  SearchVC.swift
//  Matdags
//  Created by Nicklas Gilbertson on 2017-11-08.
//  Copyright © 2017 Matdags. All rights reserved.

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class SearchVC: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var subviewBackground: UIView!
    @IBOutlet weak var subview: UIView!
    @IBOutlet weak var subviewUsername: UILabel!
    @IBOutlet weak var subviewProfileImage: UIImageView!
    @IBOutlet weak var subviewCollectionFeed: UICollectionView!
    @IBOutlet var searchUsersTableView: UITableView!
   
    let searchController = UISearchController(searchResultsController: nil)
    
    var subviewCell = [SearchSubViewCell]()
    var posts = [Post]()
    var users = [User]()
    var search = [SearchCell]()
    var filteredUsers = [User]()
    var tempUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.instance().showActivityIndicator()
        resizeImage()
        self.subview.isHidden = true
        self.subviewBackground.isHidden = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchUsersTableView.tableHeaderView = searchController.searchBar
        AppDelegate.instance().dismissActivityIndicator()
        getUserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        posts.removeAll()
        downloadImages()
        resizeImage()
    }
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        tabBarController?.selectedIndex = 2
    }
    
    @IBAction func closeSubview(_ sender: Any) {
        subview.isHidden = true
        self.subviewBackground.isHidden = true
    }
    
    @IBAction func subviewFollowUser(_ sender: Any) {
        AppDelegate.instance().addfollower()
        AppDelegate.instance().getfollower()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
        return filteredUsers.count
        } else {
        return self.users.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchCell
        cell.pictureOutlet.image = nil
        if searchController.isActive && searchController.searchBar.text != "" {
            tempUser = filteredUsers[indexPath.row]
        } else {
            tempUser = self.users[indexPath.row]
        }
        if self.users[indexPath.row].profileImageURL != "" {
            cell.pictureOutlet.downloadImage(from: self.users[indexPath.row].profileImageURL)
        } else {
            //Här kan vi sätta en default bild om användaren inte har laddat upp profilbild
            print("\n \(indexPath.row) could not return a value for profileImageURL from User. \n")
        }
        cell.usernameLabel?.text = tempUser.alias
        self.subviewUsername?.text = tempUser.alias
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.subview.isHidden = false
        self.subviewBackground.isHidden = false
        if searchController.isActive && searchController.searchBar.text != "" {
        } else {
            tempUser = self.users[indexPath.row]
            self.subviewUsername!.text = tempUser.alias
        }
    }
    
    func getUserInfo() {
        //Här hämtar vi info från varje user
        let dbref = Database.database().reference(withPath: "Users")
        dbref.queryLimited(toFirst: 20).observe(.childAdded, with: { (snapshot) in
            let tempUser = User()
            if let dictionary = snapshot.value as? [String : Any] {
                tempUser.alias = dictionary["alias"] as? String
                tempUser.uid = dictionary["uid"] as? String
                tempUser.profileImageURL = dictionary["profileImageURL"] as? String
                self.users.append(tempUser)
                self.searchUsersTableView.insertRows(at: [IndexPath(row:self.users.count-1,section:0)], with: .automatic)
            }
        })
    }
    
    func filterContent(searchText:String) {
        self.filteredUsers = self.users.filter{ user in
        return(user.alias.lowercased() == searchText.lowercased())
        }
        self.searchUsersTableView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subviewCell", for: indexPath) as! SearchSubViewCell
        cell.mySubviewCollectionFeed.image = nil
        cell.backgroundColor = .red
        if self.posts[indexPath.row].pathToImage256 != nil {
            cell.mySubviewCollectionFeed.downloadImage(from: self.posts[indexPath.row].pathToImage256)
        } else {
            print("\n \(indexPath.row) could not return a value for pathToImage256 from Post. \n")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width/4.0, height: self.view.frame.width/4.0)
        return size
    }

    func downloadImages() {
        let uid = Auth.auth().currentUser!.uid
        let dbref = Database.database().reference(withPath: "Users").child("\(uid)")
        dbref.queryLimited(toFirst: 100).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                for (_, post) in dictionary {
                    let appendPost = Post()
                    appendPost.pathToImage256 = post["pathToImage256"] as? String
                    appendPost.postID = post["postID"] as? String
                    self.posts.insert(appendPost, at: 0)
                }
            }
            self.subviewCollectionFeed.reloadData()
        })
    }
    
    func resizeImage(){
        subviewProfileImage.layer.cornerRadius = subviewProfileImage.frame.size.height / 2
        subviewProfileImage.clipsToBounds = true
        self.subviewProfileImage.layer.borderColor = UIColor.white.cgColor
        self.subviewProfileImage.layer.borderWidth = 4
    }
    
    /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     if(tabBarController?.selectedIndex == "searchResult")
     {
     if let rowNumber = sender as? Int {
     print("\n \(rowNumber) \n")
     let searchResult = tabBarController?.selectedIndex as! ProfileVC
     
     if searchController.isActive && searchController.searchBar.text != "" {
     searchResult.users = filteredUsers[rowNumber]
     } else {
     searchResult.users = users[rowNumber]
     }
     searchResult.fromSearch = true
     }
     }
     }*/
    
}
