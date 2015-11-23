//
//  DiscoverTableViewController.swift
//  OurInstagram
//
//  Created by 647 on 10/10/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.
//

/*
    This class is the UITableViewController for Discover Tab.
    Implement the search bar and search display.  User can search other users by name.
    Display suggest users for user to follow according to user's current follower.
    Allow user to tab into a certain cell to see details of that user.
*/

import UIKit
import Alamofire
import SwiftyJSON

class DiscoverTableViewController: UITableViewController, UISearchResultsUpdating {
    
    //variable for token
    let token = "2203590801.aabf771.701252ebb0f4425cbc8231c41a0e5732"
    
    //varibales for fetching suggest users data
    var recommendJson:JSON = nil
    var recommendError:AnyObject? = nil
    var recommendSorted:Array<JSON> = []
    
    //variables for fetching search data
    var searchJson:JSON = nil
    var searchError:AnyObject? = nil
    var resultSearchController = UISearchController()
    
    //cell identifier
    let cellIdentifier:String = "dicoverCell"
    
    //load table view
    override func viewDidLoad() {
        
        self.tableView.rowHeight = 60
        self.tableView.allowsSelection = true
        
        //register cell
        tableView.registerNib(UINib(nibName: "DiscoverTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        super.viewDidLoad()
        
        //define search result controller
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.active = false
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        loadRecommend()
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents:UIControlEvents.ValueChanged)
        
        self.navigationItem.title = "OurInstagram"
        
    }
    
    //handle refresh
    func handleRefresh(refreshControl: UIRefreshControl){
        loadRecommend()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //fetch suggest users data and sort by number of followers
    func loadRecommend(){
        
        let recommendUrl = "https://mobileprogram.herokuapp.com/recommendation.json"
        Alamofire.request(.GET,recommendUrl).responseJSON{
            (_,_,data,error) in
            if data != nil {
                self.recommendJson = JSON(data!)
                self.recommendError = error
                
                self.recommendSorted = self.recommendJson["data"].arrayValue
                self.recommendSorted.sort({$0["rank"] < $1["rank"]})
                
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

    // MARK: - Table view data source
    
    // Return the number of sections.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Return the number of rows in the section.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.resultSearchController.active {
            if self.searchJson == nil {
                return 0
            }
            else {
                return self.searchJson["data"].count
            }
        }
        else {
            return self.recommendSorted.count
        }
    }
    
    //assign data to cell according to row index
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DiscoverTableViewCell
        
        if self.resultSearchController.active {
            if self.searchJson != nil {
                cell.post = self.searchJson["data"][indexPath.row]
            }
        }
        else {
            cell.post = self.recommendSorted[indexPath.row]
        }
        
        return cell
    }
    
    //fetch search data and update controller
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text
        let searchUrl = "https://api.instagram.com/v1/users/search?q=\(searchText)&access_token=\(token)"
        Alamofire.request(.GET,searchUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!).responseJSON{
            (_,_,data,error) in
            if data != nil {
                self.searchJson = JSON(data!)
                self.searchError = error
                self.tableView.reloadData()
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
    
    //show user detail view when tapping the cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("userDetail", sender: self)
    }
    
    //prepare data for user detail view, define which user to show
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "userDetail" {
            let userDetailViewController = segue.destinationViewController as! UserDetailViewController
            let selectIndexPath = self.tableView.indexPathForSelectedRow()
            if self.resultSearchController.active {
                let row = selectIndexPath?.row
                userDetailViewController.id = self.searchJson["data"][row!]["id"].stringValue
                self.resultSearchController.active = false
            }
            else {
                let row = selectIndexPath?.row
                userDetailViewController.id = self.recommendSorted[row!]["id"].stringValue
            }
        }
    }
}
