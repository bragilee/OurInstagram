//
//  DiscoverTableViewCell.swift
//  OurInstagram
//
//  Created by 647 on 10/10/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.
//

/*
    This class is for discover table view cell.
    Display username and profile picture in each cell.
*/

import UIKit
import SwiftyJSON
import Haneke

class DiscoverTableViewCell: UITableViewCell {
    
    //cell outlet
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    //data assigned by table view
    var post: SwiftyJSON.JSON? {
        didSet {
            // after 'post' is assigned by a value
            self.setupPost()
        }
    }
    
    //prepare for cell reuse
    override func prepareForReuse() {
        self.profilePic.image = nil
    }
    
    //display data
    func setupPost(){
        
        if let profilePicUrl = self.post?["profile_picture"].stringValue{
            var url = NSURL(string: profilePicUrl)
            self.profilePic.hnk_setImageFromURL(url!)
        }
        self.username.text = self.post?["username"].stringValue
    }
}
