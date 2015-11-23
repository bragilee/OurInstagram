//
//  InRangeTableViewController.swift
//  OurInstagram
//
//  Created by LarryHan on 9/10/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.
//


/*
    This class is aimed to display the received photo from wifi or bluetooth and the corresponding
    peer name and time. And it also advertise to be found by other peers.
*/

import UIKit
import MultipeerConnectivity
import MBProgressHUD

class InRangeTableViewController: UITableViewController,MCSessionDelegate {

    //Variables for MPC
    let serviceType = "Local-Chat"
    var assistant: MCAdvertiserAssistant!
    var session: MCSession!
    var peerID: MCPeerID!
    
    let cellIdentifier:String = "rangeCell"
    var storeArray:[[NSString:NSString]] = []
    var sortedArray:[[NSString:NSString]] = []
    let username = "mobileprogram1234"
    
    
    
    @IBAction func backButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Photos in Range"
        
        //Set the properties of table cell.
        self.tableView.rowHeight = 100
        self.tableView.allowsSelection = false
        
        tableView.registerNib(UINib(nibName: "InRangeTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)

        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.peerID = MCPeerID(displayName: username)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        // the advertiser
        self.assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session)
        // start advertising
        self.assistant.start()
        

    }
    
    //fucntion handles pull to refresh action.
    func handleRefresh(refreshControl: UIRefreshControl){
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.storeArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! InRangeTableViewCell
        
        cell.post = self.sortedArray[indexPath.row]
        
        return cell
    }
    
    //Genearte Timestamp
    var Timestamp: String {
        return "\(NSDate().timeIntervalSince1970)"
    }
    
    // In the session method, photo is received from peers and decoded into string and stored in the array.
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        dispatch_async(dispatch_get_main_queue(), {
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.labelText = "Receiving photo from \(peerID.displayName)"
            
            var msg = NSString(data: data, encoding: NSUTF8StringEncoding)!
            var photoDic:[NSString:NSString] = ["name":"\(peerID.displayName)","time":self.Timestamp,"data":msg]
            self.storeArray.append(photoDic)
            self.sortedArray = reverse(self.storeArray)
            loadingNotification.hide(true, afterDelay:1)

        })
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
    }


}
