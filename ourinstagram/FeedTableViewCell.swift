//
//  FeedTableViewCell.swift
//  OurInstagram
//
//  Created by LarryHan on 26/09/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.
//

/*
    This class controlll the display content and action of each cell in feed table view.
*/

import UIKit
import SwiftyJSON
import Haneke
import Alamofire
import MBProgressHUD

class FeedTableViewCell: UITableViewCell {

    let username = "mobileprogram1234"
    let token = "2203590801.aabf771.701252ebb0f4425cbc8231c41a0e5732"
    
    var mediaID = ""
    var numOfLikes:Int? = 0
    var numOfComments:Int? = 0
    var likesString = ""
    var commentsString = ""
    var likeFlag = 0
    var myComment = ""
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var commentsDisplay: UILabel!
    @IBOutlet weak var comment: UITextField!
    
    
    // Send button that can post certain comment to api. Return and disply error log.
    @IBAction func send(sender: UIButton) {
        
        
        if (String(self.comment.text) != ""){
        
            self.myComment = self.comment.text
            self.comment.text = ""
            self.comment.resignFirstResponder()
            self.numOfComments = self.numOfComments! + 1
            var head = "\(numOfComments!) COMMENTS:\n"
            self.commentsString = "\(username):\(self.myComment)\n"+self.commentsString
            self.commentsDisplay.text = head + self.commentsString
            
            var commentURL = "https://api.instagram.com/v1/media/\(self.mediaID)/comments"
            
            Alamofire.request(.POST,commentURL).responseJSON{
                (_,_,data,error)->Void in
                if data != nil {
                    var hud = MBProgressHUD.showHUDAddedTo(self, animated: true)
                    hud.mode = MBProgressHUDMode.Text
                    hud.labelText = "Comment response is"
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
        
        }
        
    }
    
    @IBOutlet weak var portrait: UIImageView!
    
    @IBOutlet weak var likeOutlet: UIButton!
  
   //Like button action so that we can like or dislike and return the json error of like request.
    @IBAction func like(sender: UIButton) {
        self.likeFlag += 1
        var remain = self.likeFlag % 2
        if remain == 1{
            var likeURL = "https://api.instagram.com/v1/media/\(self.mediaID)/likes"
            
            Alamofire.request(.POST,likeURL).responseJSON{
                (_,_,data,error)->Void in
                
                if data != nil {
                    var hud = MBProgressHUD.showHUDAddedTo(self, animated: true)
                    hud.mode = MBProgressHUDMode.Text
                    hud.labelText = "Like response is"
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
            
            self.likeOutlet.setTitle("Dislike", forState: UIControlState.Normal)
            var likesHead = "\(numOfLikes! + 1) LIKES:\n"
            if self.likesString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != ""{
                self.likes.text = likesHead + "\(username)," + self.likesString
            }else{
                self.likes.text = likesHead + "\(username)" + self.likesString
            }
        }else{
            
            var dislikeURL = "https://api.instagram.com/v1/media/\(self.mediaID)/likes?access_token=\(token)"

            Alamofire.request(.DELETE,dislikeURL).responseJSON{
                (_,_,data,error)->Void in
                
                if data != nil {
                    var hud = MBProgressHUD.showHUDAddedTo(self, animated: true)
                    hud.mode = MBProgressHUDMode.Text
                    hud.labelText = "Dislike response is"
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
            
            self.likeOutlet.setTitle("Like", forState: UIControlState.Normal)
            var likesHead = "\(numOfLikes!) LIKES:\n"
            self.likes.text = likesHead + self.likesString
        }
    }
    
    
    var post: SwiftyJSON.JSON? {
        didSet {
            self.setupPost()
        }
    }
    
    override func prepareForReuse() {
        self.picture.image = nil
        self.likesString = ""
        self.commentsString = ""
        self.portrait.image = nil
        self.likeOutlet.setTitle("Like", forState: UIControlState.Normal)
    }
    
    //Format timestamp into date and time.
    func timeFormat(timestamp:Int) -> String{
        var date = NSDate(timeIntervalSince1970: Double(timestamp))
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = .MediumStyle
        let timeString = formatter.stringFromDate(date)
        return timeString
        
    }
    
    // Method to help display comments of certain media.
    func displayComments(commentsJson:SwiftyJSON.JSON)->String{
        self.numOfComments! = commentsJson["count"].intValue
        var numOfComInJson = commentsJson["data"].count
        var head = "\(self.numOfComments!) COMMENTS: \n"
        var commentsData = commentsJson["data"]
        if numOfComInJson>0{
            var numOfDisplay = min(numOfComInJson,8)
            for i in 0...(numOfDisplay-1){
                var name = commentsData[i]["from"]["username"].string!
                var text = commentsData[i]["text"].string!
                
                self.commentsString = self.commentsString+name+":"+text+"\n"
            }
        }
        return head+self.commentsString
    }
    
    func setupPost(){
        
        //Display name
        self.name.text = self.post?["user"]["username"].stringValue
        
        //Display profile picture of feed user
        if let picUrl = self.post?["images"]["low_resolution"]["url"].stringValue{
            var url = NSURL(string: picUrl)
            self.picture.hnk_setImageFromURL(url!)
        }
        
        //Display post feed picture
        if let proUrl = self.post?["user"]["profile_picture"].stringValue{
            var url = NSURL(string:proUrl)
            self.portrait.hnk_setImageFromURL(url!)
        }
        
        //Display post time
        let timeStamp = self.post?["created_time"].intValue
        self.time.text = timeFormat(timeStamp!)
        
        //Display location
        self.location.text = self.post?["location"].stringValue
        
        //Display number of likes and likes
        self.numOfLikes = self.post?["likes"]["count"].stringValue.toInt()
        var likesHead = "\(self.numOfLikes!) LIKES:\n"
        let likeArray = self.post!["likes"]["data"]
        let likeArrayLength = likeArray.count
        
        //Here got some question need to be modified
        if likeArrayLength>1{
            for ele in 0...(likeArrayLength-2){
                self.likesString = self.likesString + likeArray[ele]["username"].stringValue + ","        }
                self.likesString = self.likesString  + likeArray[likeArrayLength-1]["username"].stringValue
            
        }else if likeArrayLength>0{
            self.likesString = self.likesString  + likeArray[likeArrayLength-1]["username"].stringValue
        }
        self.likes.text = likesHead + self.likesString
        
        //Display comments
        var commentsJson = self.post?["comments"]
        self.commentsDisplay.text = displayComments(commentsJson!)
        
        //Assign MediaID
        self.mediaID = self.post!["id"].stringValue
        
        //Display location
        self.location.text = self.post?["location"]["name"].stringValue
    }
    
}
