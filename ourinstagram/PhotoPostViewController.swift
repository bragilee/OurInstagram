//  PhotoPostViewController.swift
//  OurInstagram
//
//  Created by bragi on 4/10/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.

/*
    This class is responsible for uploading image to Instagram with button pressed.
    This class provides functions to find nearby friend, set up connection with friedns using Ad hoc mechanism and send 
    image to friends by swiping on the photo.
    This class is also responsible to jumping to next view and previous view.
*/

import Foundation
import UIKit
import AssetsLibrary
import MultipeerConnectivity
import Alamofire
import SwiftyJSON
import MBProgressHUD

class PhotoPostViewController:UIViewController,UIDocumentInteractionControllerDelegate,MCBrowserViewControllerDelegate, MCSessionDelegate  {
    
    let token = "2203590801.aabf771.701252ebb0f4425cbc8231c41a0e5732"
    let name = "mobileprogram1234"
    
    var newImage = UIImage(named: "photo.igo")
    
    //Create controller to handle document interaction
    var documentController:UIDocumentInteractionController!
    
    let serviceType = "Local-Chat"
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    var session: MCSession!
    var peerID: MCPeerID!

    //Create image view to dispaly image
    @IBOutlet weak var imageView: UIImageView!

    //Go back to previous view
    @IBAction func backButton(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Call the "Instagram" application to post image
    @IBAction func photoPostButton(sender: UIButton) {
        let image = self.newImage
        let filename = "photo.igo"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, false)[0] as! NSString
        let destinationPath = documentsPath.stringByAppendingString("/" + filename)
        let f = destinationPath.stringByExpandingTildeInPath
        UIImagePNGRepresentation(image).writeToFile(f, atomically:true)
        let fileURL = NSURL(fileURLWithPath: f)! as NSURL
        
        self.documentController = UIDocumentInteractionController(URL: fileURL)
        self.documentController.delegate = self
        documentController.UTI = "com.instagram.exclusivegram"
        documentController.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: false)
    }
    
    @IBAction func findFriend(sender: UIButton) {
        self.presentViewController(self.browser, animated: true, completion: nil)
    }
    
    //View initialization with gesture idetifing
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = self.newImage
        
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        var upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        var downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)
        
        self.peerID = MCPeerID(displayName: name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        // the browser
        self.browser = MCBrowserViewController(serviceType: serviceType, session: self.session)
        self.browser.delegate = self
        
    }
    
    //Action responding to "gesture" made on the image view
    func handleSwipe(sender:UISwipeGestureRecognizer) {
            swipePhoto()
    }
    
    func swipePhoto() {
        
        var imageData = UIImagePNGRepresentation(self.newImage)
        let base64String = imageData.base64EncodedStringWithOptions(.allZeros)
        
        let msg = base64String.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        var error: NSError?
        
        //This is send
        self.session.sendData(msg, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: &error)
        
        if error == nil {
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.labelText = "Sending"
            loadingNotification.hide(true, afterDelay:1)
        }
        else {
            let alert = UIAlertView()
            alert.title = "No peers found!"
            alert.message = "Please select a peer to connect."
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    // browser delegate's methods
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        // "Done" was tapped
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        // "Cancel" was tapped
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // session delegate's methods
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        // when receiving a data
        dispatch_async(dispatch_get_main_queue(), {
            var msg = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
