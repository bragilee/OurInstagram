//
//  InRangeTableViewCell.swift
//  OurInstagram
//
//  Created by LarryHan on 9/10/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.
//

/*
    This is inrange interface that display the photos received from peers and corresponding
    name and time.
*/

import UIKit

class InRangeTableViewCell: UITableViewCell {

    var post:[NSString:NSString] = ["":""]{
        didSet{
            self.setupPost()
        }
    }

    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var peerName: UILabel!
    @IBOutlet weak var time: UILabel!

    override func prepareForReuse() {
        self.photo.image = nil
    }
    
    //This method is to update the image of each cell.
    func setupPost(){
        
        self.peerName.text = String(self.post["name"]!)
        self.time.text = String(timeFormat(self.post["time"]!.doubleValue))
        let decodedData = NSData(base64EncodedString: self.post["data"]! as String, options: NSDataBase64DecodingOptions())
        var decodedimage = UIImage(data: decodedData!)
        self.photo.image = decodedimage
    }
    
    
    func timeFormat(timestamp:Double) -> String{
        var date = NSDate(timeIntervalSince1970: Double(timestamp))
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = .MediumStyle
        let timeString = formatter.stringFromDate(date)
        return timeString
        
    }
    
    
}
