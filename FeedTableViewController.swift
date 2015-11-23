//
//  FeedTableViewController.swift
//  OurInstagram
//
//  Created by LarryHan on 24/09/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.
//


/*
    This class is responsible for control the feedtableview that can display the user feeds.
    Display and make like and comment on this post.
*/

import UIKit
import Alamofire
import SwiftyJSON


class FeedTableViewController: UITableViewController,UITextFieldDelegate  {
    
    let token = "2203590801.aabf771.701252ebb0f4425cbc8231c41a0e5732"
    var feedJson:Array<JSON> = []
    var rawJson:Array<JSON> = []
    var feedError:AnyObject? = nil
    let cellIdentifier:String = "feedCell"
    var sortFlag = 0
    var nextUrl = ""

    @IBAction func segSort(sender: UISegmentedControl) {
        var selected = sender.selectedSegmentIndex
        self.sortFlag = selected
    }
    
    override func viewDidLoad() {
        //Set the property and register cell.
        self.tableView.rowHeight = 589
        self.tableView.allowsSelection = false
        tableView.registerNib(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        super.viewDidLoad()
        
        loadFeed()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.navigationItem.title = "OurInstagram"

        
    }

    
    func handleRefresh(refreshControl: UIRefreshControl){
        loadFeed()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // This sortByLocation function is to sort the feeds by loaction alphabetically.
    func sortByLocation(rawJson:Array<JSON>)->Array<JSON>{
        
        var sorted:Array<JSON> = []
        var empty:Array<JSON> = []
        for ele in rawJson{
            if (ele["location"]["name"].string?.isEmpty != nil){
                sorted.append(ele)
            }else{
                empty.append(ele)
            }
            
        }
        sorted.sort({$0["location"]["name"].string < $1["location"]["name"].string})
        return (sorted+empty)
    }
    
    // This reloadFeed() method helps make api request and display more feed cell when the tableview reaches the bottom.
    func reloadFeed(requestUrl:String){
        Alamofire.request(.GET,requestUrl).responseJSON{
            (_,_,data,error) in
            if data != nil {
                var tempJson = JSON(data!)
                self.nextUrl = tempJson["pagination"]["next_url"].string!
                
                if(self.sortFlag == 0){
                    self.rawJson = self.rawJson + tempJson["data"].arrayValue
                }else{
                    self.rawJson = self.rawJson + self.sortByLocation(tempJson["data"].arrayValue)
                }
                self.feedJson = self.rawJson
                self.tableView.reloadData()

            }
            else {
                let alert = UIAlertView()
                alert.title = "Network Error!"
                alert.message = "Sorry, no network connection!"
                alert.addButtonWithTitle("OK")
                alert.show()
            }
        }
        
        
    }
    
    // The loadFeed() is used to display user feed when starts the view or pull to refresh this view.
    func loadFeed(){
        let feedUrl = "https://api.instagram.com/v1/users/self/feed?access_token=\(token)"
        Alamofire.request(.GET,feedUrl).responseJSON{
            (_,_,data,error) in
            if data != nil {
                var tempJson = JSON(data!)
                self.nextUrl = tempJson["pagination"]["next_url"].string!
                self.rawJson = tempJson["data"].arrayValue
                
                if (self.sortFlag == 0){
                    self.feedJson = self.rawJson
                }else{
                    self.feedJson = self.sortByLocation(self.rawJson)
                }
                
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            }
            else {
                self.refreshControl!.endRefreshing()
                let alert = UIAlertView()
                alert.title = "Network Error!"
                alert.message = "Sorry, no network connection!"
                alert.addButtonWithTitle("OK")
                alert.show()
                
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
     
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return self.feedJson.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FeedTableViewCell
        cell.comment.delegate = self
        cell.post = self.feedJson[indexPath.row]
        
        // When reaches the last cell of the table cell, do the reload method.
        if (indexPath.row == self.feedJson.count-1){
            self.reloadFeed(self.nextUrl)
        }
        
        return cell
    }
    
    func textFieldShouldReturn(comment: UITextField) -> Bool {
        comment.resignFirstResponder()
        return true
    }
}
