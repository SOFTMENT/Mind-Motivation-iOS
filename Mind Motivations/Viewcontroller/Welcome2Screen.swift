//
//  Welcome2Screen.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 19/10/22.
//

import UIKit
import Firebase
import FirebaseAuth
class Welcome2Screen : UIViewController {
   
   
    override func viewDidLoad() {
        
        if let user = Auth.auth().currentUser  {
            
            MyAudioPlayer.sharedInstance.playBackground()
    
            self.getUserData(uid: user.uid, showProgress: false)
        }
        
    }
    
   
}
