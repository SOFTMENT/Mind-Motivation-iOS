//
//  MusicModel.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 19/11/22.
//

import UIKit

class MusicModel : NSObject, Codable {
    
    var id : String?
    var title : String?
    var thumbnail : String?
    var musicUrl : String?
    var duration : Int?
    var catId : String?
    var catName : String?
    var about : String?
    var createdDate : Date?
    var artistName : String?
    var genre : String?
    
    
}
