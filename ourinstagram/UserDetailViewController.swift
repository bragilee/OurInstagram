//
//  UserDetailViewController.swift
//  ourinstagram
//
//  Created by 647 on 12/10/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.
//

/*
    This class is for user detail view controller.
    Fetch user detail data of certain user according to user id.
    Display user detail data.
*/

import UIKit
import Alamofire
import SwiftyJSON
import Haneke
import MBProgressHUD

class UserDetailViewController: UIViewController {
    
    //variable for user id
    var id: String = ""
    
    //variable for token
    let token = "2203590801.aabf771.701252ebb0f4425cbc8231c41a0e5732"
    
    //variable for fetching user detail data
    var userDetailJson: SwiftyJSON.JSON = nil
    var userDetailError: AnyObject? = nil
    
    //flag for whether tap follow button
    var followFlag = 0
    
    //variable for outlet
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postsCount: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var followingsCount: UILabel!
    
    @IBOutlet weak var followOutlet: UIButton!
    
    //follow button function
    //send follow or unfollow request when tapped
    @IBAction func follow(sender: UIButton) {
        
        self.followFlag += 1
        var remain = self.followFlag % 2
        if remain == 1 {
            
            var followUrl = "https://api.instagram.com/v1/users/\(id)/relationship?access_token=\(token)&action=follow"
            
            Alamofire.request(.POST,followUrl).responseJSON{
                (_,_,data,error)->Void in
                
                if data != nil {
                    var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    print(hud.dynamicType)
                    hud.mode = MBProgressHUDMode.Text
                    hud.labelText = "Follow response is"
                    hud.detailsLabelText = "\(data)"
                    hud.hide(true, afterDelay: 1)
                }
                else{
                    let alert = UIAlertView()
                    alert.title = "Network Error!"
                    alert.message = "Sorry, no network connection!"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            }
            
            self.followOutlet.setTitle("UnFollow", forState: UIControlState.Normal)
            
        }
        else {
            
            var unfollowUrl = "https://api.instagram.com/v1/users/\(id)/relationship?access_token=\(token)&action=unfollow"
            
            Alamofire.request(.POST,unfollowUrl).responseJSON{
                (_,_,data,error)->Void in
                
                if data != nil {
                    var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    print(hud.dynamicType)
                    hud.mode = MBProgressHUDMode.Text
                    hud.labelText = "UnFollow response is"
                    hud.detailsLabelText = "\(data)"
                    hud.hide(true, afterDelay: 1)
                }
                else{
                    let alert = UIAlertView()
                    alert.title = "Network Error!"
                    alert.message = "Sorry, no network connection!"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            }
            
            self.followOutlet.setTitle("Follow", forState: UIControlState.Normal)
            
        }
    }
    
    //load view
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.loadUserDetail()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //fetch user detail data
    func loadUserDetail(){
        
        let userDetailUrl = "https://api.instagram.com/v1/users/\(id)/?access_token=\(token)"
        
        Alamofire.request(.GET,userDetailUrl).responseJSON{
            (_,_,data,error) in
            
            if data != nil {
                self.userDetailJson = JSON(data!)
                self.userDetailError = error
                
                self.showDetail()
            }
            else{
                let alert = UIAlertView()
                alert.title = "Network Error!"
                alert.message = "Sorry, no network connection!"
                alert.addButtonWithTitle("OK")
                alert.show()
            }
        }
    }
    
    //display user detial data
    func showDetail(){
        
        var profilePicUrl = self.userDetailJson["data"]["profile_picture"].stringValue
        var url = NSURL(string: profilePicUrl)
        self.profilePic.hnk_setImageFromURL(url!)
        
        self.username.text = self.userDetailJson["data"]["username"].stringValue
        
        var postsNum = self.userDetailJson["data"]["counts"]["media"].intValue
        if postsNum >= 10000 {
            postsNum /= 1000
            self.postsCount.text = String(postsNum) + "k"
        }
        else {
            self.postsCount.text = String(postsNum)
        }
        
        var followersNum = self.userDetailJson["data"]["counts"]["followed_by"].intValue
        if followersNum >= 10000 {
            followersNum /= 1000
            self.followersCount.text = String(followersNum) + "k"
        }
        else {
            self.followersCount.text = String(followersNum)
        }
        
        var followingsNum = self.userDetailJson["data"]["counts"]["follows"].intValue
        if followingsNum >= 10000 {
            followingsNum /= 1000
            self.followingsCount.text = String(followingsNum) + "k"
        }
        else {
            self.followingsCount.text = String(followingsNum)
        }
    }
}
