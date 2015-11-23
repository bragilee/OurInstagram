//
//  ActivityTableViewCell.swift
//  OurInstagram
//
//  Created by 647 on 10/10/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.
//

/*
    This class is for activity table view cell.
    Display information of posts and start follows of users whom the current user follows in each cell in Following segment.
    Display information of likes and start follows of current user in each cell in You segment.
*/

import UIKit
import SwiftyJSON
import Haneke

class ActivityTableViewCell: UITableViewCell {
    
    //variables for outlet
    @IBOutlet weak var option: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var mediaPic: UIImageView!
    @IBOutlet weak var followUsername: UILabel!
    
    //data assigned by table view
    var post: SwiftyJSON.JSON? {
        didSet {
            self.setupPost()
        }
    }
    
    //prepare for cell reuse
    override func prepareForReuse() {
        self.profilePic.image = nil
        self.mediaPic.image = nil
        self.followUsername.text = nil
    }
    
    //display data
    func setupPost(){
        
        var timeStamp = self.post?["time"].intValue
        self.time.text = timeFormat(timeStamp!)
        
        if let profilePicUrl = self.post?["profile_picture"].stringValue{
            var url = NSURL(string: profilePicUrl)
            self.profilePic.hnk_setImageFromURL(url!)
        }
        
        self.username.text = self.post?["username"].stringValue
        
        if self.post?["followUsername"].stringValue == "" {
            
            if self.post?["image"].stringValue == "" {
                self.option.text = "I start follow"
            }
            else {
                self.option.text = "I like"
                if let mediaPicUrl = self.post?["image"].stringValue{
                    var url = NSURL(string: mediaPicUrl)
                    self.mediaPic.hnk_setImageFromURL(url!)
                }
            }
        }
        else{
            
            if self.post?["image"].stringValue == "" {
                self.option.text = "start follow"
                self.followUsername.text = self.post?["followUsername"].stringValue
            }
            else {
                self.option.text = "post"
                if let mediaPicUrl = self.post?["image"].stringValue{
                    var url = NSURL(string: mediaPicUrl)
                    self.mediaPic.hnk_setImageFromURL(url!)
                }
            }
        }
    }
    
    //change format of timestamp to datetime
    func timeFormat(timestamp:Int) -> String{
        
        var date = NSDate(timeIntervalSince1970: Double(timestamp))
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = .MediumStyle
        let timeString = formatter.stringFromDate(date)
        return timeString
    }
    
}
