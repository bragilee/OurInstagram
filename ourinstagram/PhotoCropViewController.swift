//  PhotoCropViewController.swift
//  OurInstagram
//
//  Created by bragi on 4/10/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.

/*  
    This class provides user with functions to crop photos.
    This class is also responsible for jumping to the next view and previous view.
*/

import Foundation
import UIKit
import CoreImage
import CoreGraphics

class PhotoCropViewController:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,
UIScrollViewDelegate {
    
    var newImage:UIImage!

    var imageView = UIImageView()
    
    var cropImage:UIImage!
    
    //Create a scroll view
    @IBOutlet weak var scrollView: UIScrollView!

    //Go back to previous view
    @IBAction func backButton(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Create a scroll view and initialize its settings
    //Create a image view inside to display image
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = self.newImage
                
        self.scrollView.delegate = self
        self.imageView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)
        
        self.imageView.userInteractionEnabled = true
        self.scrollView.addSubview(self.imageView)
        
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageView.frame = CGRectMake(0, 0, self.newImage.size.width, self.newImage.size.height)
        self.scrollView.contentSize = self.newImage.size
        
        let scrollViewFrame = self.scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width
        let scaleHeight  = scrollViewFrame.size.height / self.scrollView.contentSize.height
        let minScale = min(scaleHeight,scaleWidth)
        
        self.scrollView.minimumZoomScale = minScale
        self.scrollView.maximumZoomScale = 1
        self.scrollView.zoomScale = minScale
        
        centerScrollViewContent()
    }
    
    //Display image in the center in the scroll view
    func centerScrollViewContent() {
        let boundsSize = self.scrollView.bounds.size
        var contentsFrame = self.imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        }
        else {
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        }
        else {
            contentsFrame.origin.y = 0
        }
        self.imageView.frame = contentsFrame
    }
    
    //Adjust view to center
    func scrollDidZoom(scollView: UIScrollView) {
        centerScrollViewContent()
    }
    
    //Adjust the view when the user is manipulating with gestures
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    //Pass the current image to desitnation view when the veiw is jumping to the next view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {        
        UIGraphicsBeginImageContextWithOptions(self.scrollView.bounds.size, true, UIScreen.mainScreen().scale)
        let offset = self.scrollView.contentOffset
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -offset.x, -offset.y)
        self.scrollView.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        imageView.image = image
        UIGraphicsEndImageContext()

        if segue.identifier == "PhotoEdit" {
            let destinationViewController = segue.destinationViewController as! PhotoEditViewController
            destinationViewController.newImage = self.imageView.image
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}