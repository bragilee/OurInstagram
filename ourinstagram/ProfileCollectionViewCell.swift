//
//  ProfileCollectionViewCell.swift
//  OurInstagram
//
//  Created by LarryHan on 11/10/2015.
//  Copyright (c) 2015 LarryHan. All rights reserved.
//

/*
    This class is the cell of the Collection View in the PorfileViewController.
*/

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {

    
    //Create an image view for each cell
    @IBOutlet weak var imageEachCell: UIImageView!
    
    override func prepareForReuse() {
        self.imageEachCell.image = nil
    }

}
