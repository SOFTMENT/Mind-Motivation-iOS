//
//  MyGesture.swift
//  eventkreyol
//
//  Created by Apple on 06/08/21.
//

import UIKit

class MyGesture: UITapGestureRecognizer {
    
    var index : Int = -1
    var id : String = ""
    var organizerUid : String?
    var latitude : Double?
    var longitude : Double?
    var mView : UIView?
    var url : String?
    var musicCell : PlaylistTableViewCell?
   
    
}
