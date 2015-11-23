//  PhotoEditViewController.swift
//  OurInstagram
//
//  Created by bragi on 4/10/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.

/*
    This class provides users with functions to edit images. Three filters are provided and the user can also 
    change the brightness and contrast of the image.
    Besides, "Reset" button is deployed to reload the original image and user can save image after adjustment.
    This class is also responsible to jumping to next view and previous view.
*/

import Foundation
import UIKit
import CoreImage
import CoreGraphics
import AssetsLibrary

class PhotoEditViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var newImage: UIImage!
    
    var originalImage: UIImage!
    
    var rawImage: UIImage!
    
    //Create image view
    @IBOutlet weak var imageEditView: UIImageView!
    
    //Go back to previous view
    @IBAction func backButton(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Save the image when pressed
    @IBAction func photoSaveButton(sender: UIButton) {
        var imageToSave = CIImage(image: self.newImage)
        let softwareContext = CIContext(options:[kCIContextUseSoftwareRenderer: true])
        let cgimg = softwareContext.createCGImage(imageToSave, fromRect:imageToSave.extent())
        let library = ALAssetsLibrary()
        library.writeImageToSavedPhotosAlbum(cgimg,
            metadata:imageToSave.properties(),
            completionBlock:nil)
    }
    
    //Show the original photo without effectiveness
    @IBAction func photoOriginalButton(sender: UIButton) {
        self.imageEditView.image = self.originalImage
    }
    
    //Filter the image into "SepiaTone" effectiveness
    @IBAction func photoSepiaToneButton(sender: UIButton) {
        
        var CurrentImage = self.imageEditView.image
        var inputImage = CIImage(image:CurrentImage)
        let filter = CIFilter(name:"CISepiaTone")
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(0.5, forKey: kCIInputIntensityKey)
        let filteredImage = filter.outputImage
        let context = CIContext(options: nil)
        let finalImage = context.createCGImage(filteredImage, fromRect: filteredImage.extent())
        self.imageEditView.image =  UIImage(CGImage: finalImage)
    }
    
    //Filter the image into "Transfer" effectiveness
    @IBAction func photoTransferButton(sender: UIButton) {
        var CurrentImage = self.imageEditView.image
        var inputImage = CIImage(image:CurrentImage)
        let filter = CIFilter(name:"CIPhotoEffectTransfer")
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        let filteredImage = filter.outputImage
        let finalImage =  context.createCGImage(filteredImage  , fromRect: filteredImage.extent())
        self.imageEditView.image =  UIImage(CGImage: finalImage)
    }

    //Filter the image into "Mono" effectiveness
    @IBAction func photoMonoButton(sender: UIButton) {
        var CurrentImage = self.imageEditView.image
        var inputImage = CIImage(image:CurrentImage)
        let filter = CIFilter(name:"CIPhotoEffectMono")
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        let filteredImage = filter.outputImage
        let finalImage =  context.createCGImage(filteredImage  , fromRect: filteredImage.extent())
        self.imageEditView.image =  UIImage(CGImage: finalImage)
    }

    //Crate Slider bar to control brightness pf image
    @IBOutlet weak var photoBrightness: UISlider!
    
    //Adjust the brgihtness of image when slider bar is moving
    @IBAction func photoBrightnessChange(sender: UISlider) {
        var aCIImage = CIImage()
        var brightnessFilter: CIFilter!
        var context = CIContext()
        var outputImage = CIImage()
        var newUIImage = UIImage()
        
        var aUIImage = self.newImage
        var aCGImage = aUIImage?.CGImage
        aCIImage = CIImage(CGImage: aCGImage)
        
        context = CIContext(options: nil)
        brightnessFilter = CIFilter(name: "CIColorControls")
        brightnessFilter.setValue(aCIImage, forKey: "inputImage")
        
        brightnessFilter.setValue(NSNumber(float: sender.value), forKey: "inputBrightness")
        outputImage = brightnessFilter.outputImage
        let imageRef = context.createCGImage(outputImage, fromRect: outputImage.extent())
        newUIImage = UIImage(CGImage: imageRef)!
        self.imageEditView.image = newUIImage
    }
    
    //Create Slider bar to control contrast of image
    @IBOutlet weak var photoContrast: UISlider!
    
    //Adjust the contrast of image when slider bar is moving
    @IBAction func photoContrastChange(sender: UISlider) {
        var aCIImage = CIImage()
        var contrastFilter: CIFilter!
        var context = CIContext()
        var outputImage = CIImage()
        var newUIImage = UIImage()
        
        var aUIImage = self.rawImage
        var aCGImage = aUIImage?.CGImage
        aCIImage = CIImage(CGImage: aCGImage)
        
        context = CIContext(options: nil)
        contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter.setValue(aCIImage, forKey: "inputImage")
        
        contrastFilter.setValue(NSNumber(float: sender.value), forKey: "inputContrast")
        outputImage = contrastFilter.outputImage
        var cgimg = context.createCGImage(outputImage, fromRect: outputImage.extent())
        newUIImage = UIImage(CGImage: cgimg)!
        self.imageEditView.image = newUIImage
    }
    
    //Pass the current image to destination view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PhotoPost" {
            let destinationViewController = segue.destinationViewController as! PhotoPostViewController
            destinationViewController.newImage = self.imageEditView.image
        }
    }
    
    //Load the image when the view displays
    override func viewDidLoad() {
        super.viewDidLoad()
        self.originalImage = self.newImage
        self.rawImage = self.newImage
        self.imageEditView.image = self.newImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}