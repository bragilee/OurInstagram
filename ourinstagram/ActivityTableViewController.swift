//
//  ActivityTableViewController.swift
//  OurInstagram
//
//  Created by 647 on 10/10/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.
//

/*
    This class is the UITableViewController for activity tab.
    Display the posts and start follows of users whom the current user follows in Following segment.
    Display the likes and start follows of current user in You segment
*/

import UIKit
import Alamofire
import SwiftyJSON

class ActivityTableViewController: UITableViewController {
    
    //variable for token
    let token = "2203590801.aabf771.701252ebb0f4425cbc8231c41a0e5732"
    
    //varibales for fetching data in Following segment
    var followingJson:JSON = nil
    var followingError:AnyObject? = nil
    var followingSorted:Array<JSON> = []
    
    //variables for fetching data in You segment
    var youJson:JSON = nil
    var youError:AnyObject? = nil
    var youSorted:Array<JSON> = []
    
    //cell identifier
    let cellIdentifier:String = "activityCell"
    
    //variable for segment controller
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //reload data when change segment
    @IBAction func changeTab(sender: UISegmentedControl) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            loadFollowing()
        case 1:
            loadYou()
        default:
            break;
        }
    }
    
    //load view
    override func viewDidLoad() {
        
        self.tableView.rowHeight = 100
        self.tableView.allowsSelection = false
        
        //register cell
        tableView.registerNib(UINib(nibName: "ActivityTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        super.viewDidLoad()
        
        loadFollowing()
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.navigationItem.title = "OurInstagram"

    }
    
    // handle refresh
    func handleRefresh(refreshControl: UIRefreshControl){
        
        if self.segmentedControl.selectedSegmentIndex == 0 {
            loadFollowing()
        }
        else{
            loadYou()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //fetch data for Following segment
    func loadFollowing(){
        
        let followingUrl = "https://mobileprogram.herokuapp.com/following.json"
        
        Alamofire.request(.GET,followingUrl).responseJSON{
            (_,_,data,error) in
            
            if data != nil {
                self.followingJson = JSON(data!)
                self.followingError = error
                
                self.followingSorted = self.followingJson["data"].arrayValue
                self.followingSorted.sort({$0["time"] > $1["time"]})
                
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
            }
            else{
                self.refreshControl!.endRefreshing()
                let alert = UIAlertView()
                alert.title = "Network Error!"
                alert.message = "Sorry, no network connection!"
                alert.addButtonWithTitle("OK")
                alert.show()
            }
        }
    }
    
    //fetch data for You segment
    func loadYou(){
        
        let youUrl = "https://mobileprogram.herokuapp.com/you.json"
        
        Alamofire.request(.GET,youUrl).responseJSON{
            (_,_,data,error) in
            
            if data != nil {
                self.youJson = JSON(data!)
                self.youError = error
                
                self.youSorted = self.youJson["data"].arrayValue
                self.youSorted.sort({$0["time"] > $1["time"]})
                
                self.tableView.reloadData()
                self.refreshControl!.endRefreshing()
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

    // MARK: - Table view data source
    
    // Return the number of sections.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // Return the number of rows in the section.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.segmentedControl.selectedSegmentIndex == 0 {
            return self.followingSorted.count
        }
        else{
            return self.youSorted.count
        }
    }
    
    //assign data to cell according to row index
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ActivityTableViewCell
        
        if self.segmentedControl.selectedSegmentIndex == 0 {
            cell.post = self.followingSorted[indexPath.row]
        }
        else{
            cell.post = self.youSorted[indexPath.row]
        }
        
        return cell
    }
}
