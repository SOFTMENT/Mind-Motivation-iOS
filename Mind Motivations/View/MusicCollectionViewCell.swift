//
//  MusicCollectionViewCell.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 14/10/22.
//

import UIKit

class MusicCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var mView: UIView!
    
    @IBOutlet weak var categoryImage: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var totalTracks: UILabel!
    override class func awakeFromNib() {
       
    }
    
    
}
