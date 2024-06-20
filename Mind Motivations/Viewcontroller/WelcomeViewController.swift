//
//  WelcomeViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 13/10/22.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase

class WelcomeViewController: UIViewController {
   
    let userDefaults = UserDefaults.standard
    override func viewDidLoad() {
        
        //SUBSCRIBE TO TOPIC
        Messaging.messaging().subscribe(toTopic: "mindmotivations"){ error in
            if error == nil{
                print("Subscribed to topic")
            }
            else{
                print("Not Subscribed to topic")
            }
        }
        
        
        if userDefaults.value(forKey: "appFirstTimeOpend") == nil {
            //if app is first time opened then it will be nil
            userDefaults.setValue(true, forKey: "appFirstTimeOpend")
            // signOut from FIRAuth
            do {
                try Auth.auth().signOut()
            }catch {

            }
            // go to beginning of app
        }
        

      
        
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async {
                if Auth.auth().currentUser!.isAnonymous {
                    
                    self.beRootScreen(mIdentifier: Constants.StroyBoard.tabBarViewController)
                }
                
                
                else {
                    if Auth.auth().currentUser?.uid == "LYV2GwFQSTc937U526aP4klO4X42" {
                        
                        DispatchQueue.main.async {
                            self.beRootScreen(mIdentifier: Constants.StroyBoard.adminTabBarViewController)
                        }
                    }
                    else {
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.welcome2ViewController)
                        
                    }
                    
                }
                
            }
            }
                else {
         
               self.gotoSignInViewController()
            
        }
             
          
        
               
    }
    
    func gotoSignInViewController(){
        DispatchQueue.main.async {
            self.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
        }
    }
    
}
