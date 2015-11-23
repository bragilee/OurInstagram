//
//  ProfileViewController.swift
//  ourinstagram
//
//  Created by LarryHan on 13/10/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.
//


/*
    This class is to display the profile of the user. Include a scroll view and some text,images and a collection in it.
    It handles pull to display the collection view and pull to refresh the whole interface.
*/

import UIKit
import Alamofire
import SwiftyJSON

class ProfileViewController: UIViewController,UIScrollViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate {
    
    var refreshControl:UIRefreshControl!
    let token = "2203590801.aabf771.701252ebb0f4425cbc8231c41a0e5732"
    var infoJson:JSON = nil
    var photoJson:JSON = nil
    var jasonError:AnyObject? = nil
    var cellIdentifier = "Cell"
    
    //Create a scroll view
    @IBOutlet var scrollView: UIScrollView!
    
    //Create the text components on the profile screen
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var numPost: UILabel!
    @IBOutlet weak var numFlwer: UILabel!
    @IBOutlet weak var numFlwing: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    //Create a collection view to display all photos uploaded
    @IBOutlet weak var profileCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initiate the setting of the scroll view and pull to refresh
        self.scrollView.scrollEnabled = true
        self.scrollView.alwaysBounceVertical = true
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.scrollView.addSubview(refreshControl)
        
        //Display the title on the navigation bar
        self.navigationItem.title = "OurInstagram"
        
        //Initiate the setting of the collection view and the format of cells
        var flow:UICollectionViewFlowLayout = self.profileCollectionView.collectionViewLayout as!
        UICollectionViewFlowLayout
        flow.itemSize = CGSizeMake(80, 80)
        var nipName=UINib(nibName: "ProfileCollectionViewCell", bundle:nil)
        self.profileCollectionView.registerNib(nipName, forCellWithReuseIdentifier: cellIdentifier)
        
        //Load profile information and photos uploaded when the view displays
        loadProfile()
        loadCollectionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }
    
    //Define the contents to be updated during refresh
    func refresh(sender:AnyObject)
    {
        loadProfile()
        loadCollectionView()
        self.refreshControl.endRefreshing()
    }
    
    //Get user profile information using API
    func loadProfile() {
        let infoUrl = "https://api.instagram.com/v1/users/self/?access_token=\(token)"
        Alamofire.request(.GET,infoUrl).responseJSON{
            (_,_,data,error) in
            
        if data != nil {
            self.infoJson = JSON(data!)
            self.jasonError = error
            self.infoJson = self.infoJson["data"]
                
            //Get user's full name
            self.name.text = self.infoJson["full_name"].stringValue
                
            //Get user's profile picture
            let picUrl = self.infoJson["profile_picture"].stringValue
            var url = NSURL(string: picUrl)
            self.profilePic.hnk_setImageFromURL(url!)
            //Turn the shape of profile picture into a circle
            self.profilePic.layer.cornerRadius = self.profilePic.frame.size.height/2
            self.profilePic.layer.masksToBounds = true
            self.profilePic.layer.borderWidth = 0
                
            //Get stats on posts, followers, following and the username
            self.userName.text = self.infoJson["username"].stringValue
            self.numPost.text = self.infoJson["counts"]["media"].stringValue
            self.numFlwer.text = self.infoJson["counts"]["followed_by"].stringValue
            self.numFlwing.text = self.infoJson["counts"]["follows"].stringValue
        }
        else {
            //Handle network error
            self.refreshControl.endRefreshing()
            let alert = UIAlertView()
            alert.title = "Network Error!"
            alert.message = "Sorry, no network connection!"
            alert.addButtonWithTitle("OK")
            alert.show()
            }
        }
    }
    
    //Get all uploaded photos using API
    func loadCollectionView(){
        let infoUrl = "https://api.instagram.com/v1/users/self/media/recent/?access_token=\(token)"
        Alamofire.request(.GET,infoUrl).responseJSON{
            (_,_,data,error) in
            
        if data != nil {
            self.photoJson = JSON(data!)
            self.photoJson = self.photoJson["data"]
            //data source of the collection view
            self.profileCollectionView.reloadData()
            self.jasonError = error
        }
        else {
            //Handle network error
            let alert = UIAlertView()
            alert.title = "Network Error!"
            alert.message = "Sorry, no network connection!"
            alert.addButtonWithTitle("OK")
            alert.show()
            }
        }
    }
    
    //There is only one section in the collection view on the profile screen
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //return the total number of uploaded photos
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoJson.count
    }
    
    //Display all obtained photos in the collection view
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: ProfileCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! ProfileCollectionViewCell
        //Get the url of the photo to be displayed
        let photoUrl = self.photoJson[indexPath.row]["images"]["thumbnail"]["url"].stringValue
        var url = NSURL(string: photoUrl)
        //Display one photo per cell
        cell.imageEachCell.hnk_setImageFromURL(url!)
        return cell
    }

}
