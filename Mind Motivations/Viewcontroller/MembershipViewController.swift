//
//  MembershipViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 30/07/23.
//

import UIKit
import RevenueCat
import Firebase
import FirebaseFirestore

class MembershipViewController : UIViewController, UIDocumentInteractionControllerDelegate {
    @IBOutlet weak var mostPopular: UIButton!
    
    
    @IBOutlet weak var blackTierView: UIView!
    
    @IBOutlet weak var blackTierCheckBox: UIButton!
 
    @IBOutlet weak var platinumTierView: UIView!
    
    @IBOutlet weak var plantinumTierCheckBox: UIButton!
    @IBOutlet weak var backView: UIView!
    
    
    
    @IBOutlet weak var subscribeNowBtn: UIButton!
    
    
    @IBOutlet weak var restoreBtn: UILabel!
    
    
    @IBOutlet weak var termsOfUse: UILabel!
    
    @IBOutlet weak var privacyPolicy: UILabel!
    
   
    var membershipType = ""
    var type = ""
    
    override func viewDidLoad() {
        
        mostPopular.layer.cornerRadius = 8
    
        blackTierView.layer.cornerRadius = 8
        blackTierView.isUserInteractionEnabled = true
        blackTierView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(blackTierClicked)))
        
        platinumTierView.layer.cornerRadius = 8
        platinumTierView.isUserInteractionEnabled = true
        platinumTierView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(platinumTierClicked)))
        
      
        subscribeNowBtn.layer.cornerRadius = 8
        
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius  = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewClicked)))

    }

    
    @objc func backViewClicked(){
        self.logout()
    }
    
    @objc func blackTierClicked(){
        blackTierCheckBox.isSelected = true
      
        plantinumTierCheckBox.isSelected = false
       
        membershipType = "BLACK"
    }
    
    @objc func platinumTierClicked(){
        blackTierCheckBox.isSelected = false
      
        plantinumTierCheckBox.isSelected = true
       
        membershipType = "PLATINUM"
    }
    

    
    @objc func restoreClicked(){
        self.ProgressHUDShow(text: "Restoring...")
        Purchases.shared.restorePurchases { customerInfo, error in
            self.ProgressHUDHide()
            if customerInfo?.entitlements.all["Premium"]?.isActive == true {
                Constants.expireDate = customerInfo?.entitlements.all["Premium"]?.expirationDate ?? Date()
                Constants.membershipType = customerInfo?.entitlements.all["Premium"]?.productIdentifier ?? "FREE"
                
                Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).setData(["membershipType" : Constants.membershipType], merge: true)
             
                self.beRootScreen(mIdentifier: Constants.StroyBoard.tabBarViewController)
            }
            else {
                self.showSnack(messages: "No active membership found")
            }
        }
    }
    
    @objc func termsOfUseClicked(){
        if let termsAndConditionsFilePath = Bundle.main.path(forResource: "Terms And Conditions", ofType: "pdf")  {
            let dc = UIDocumentInteractionController(url: URL(fileURLWithPath: termsAndConditionsFilePath))
            dc.delegate = self
            dc.presentPreview(animated: true)
        }

    }
    
    @objc func privacyPolicyClicked(){
        if let privacyFilePath = Bundle.main.path(forResource: "Privacy Policy", ofType: "pdf")  {
            let dc = UIDocumentInteractionController(url: URL(fileURLWithPath: privacyFilePath))
            dc.delegate = self
            dc.presentPreview(animated: true)
        }
    }
    

    
    @IBAction func subscribeNowClicked(_ sender: Any) {
       
        self.ProgressHUDShow(text: "")
        
            Purchases.shared.getOfferings { (offerings, error) in
                if let offerings = offerings {
                    var package : Package?
                   
                    
                    if self.membershipType == "BLACK" {
                        package = offerings.current?.availablePackages[0]
                    }
                    else if self.membershipType == "PLATINUM" {
                        package = offerings.current?.availablePackages[1]
                    }
        
                    Purchases.shared.purchase(package: package!) { (transaction, customerInfo, error, userCancelled) in
                       
                        if let error = error {
                            self.ProgressHUDHide()
                            self.showError(error.localizedDescription)
                        }
                        else {
    
                            if customerInfo?.entitlements.all["Premium"]?.isActive == true {
                                Constants.expireDate = customerInfo?.entitlements.all["Premium"]?.expirationDate ?? Date()
                                let identifier = customerInfo?.entitlements.all["Premium"]?.productIdentifier ?? "FREE"
                                if identifier == "in.softment.mindmotivations.monthly" {
                                    Constants.membershipType = "MONTHLY"
                                }
                                else if identifier == "in.softment.mindmotivations.yearly" {
                                    Constants.membershipType = "YEARLY"
                                   
                                }
                                self.beRootScreen(mIdentifier: Constants.StroyBoard.tabBarViewController)
                            }
    
                        }
                    }
                
           
              }
           
                else {
                    self.showError(error!.localizedDescription)
                }
            }
       

    }
    
}


