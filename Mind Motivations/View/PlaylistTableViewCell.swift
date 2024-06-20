//
//  PlaylistTableViewCell.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 10/11/22.
//

import UIKit

class PlaylistTableViewCell : UITableViewCell {
    

    @IBOutlet weak var mView: UIView!
    
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var musicTrack: UILabel!
    
    @IBOutlet weak var favImage: UIImageView!
    
    @IBOutlet weak var favView: UIView!
    override class func awakeFromNib() {
        
    }
    
}
