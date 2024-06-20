//
//  ProfileViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 14/10/22.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController : UIViewController, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var aboutUsView: UIView!
    @IBOutlet weak var privacyPolicyView: UIView!
    @IBOutlet weak var deleteAccountView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var termsAndConditionsView: UIView!
    
    @IBOutlet weak var faqsView: UIView!
    
    @IBOutlet weak var faqBtn: UIView!
    @IBOutlet weak var disclaimerView: UIView!
    

    @IBOutlet weak var disclaimerBtn: UIView!
    @IBOutlet weak var helpCenterView: UIView!
    
    @IBOutlet weak var notificationBtn: UIView!
    @IBOutlet weak var aboutUsBtn: UIView!
    @IBOutlet weak var privacyPolicyBtn: UIView!
    @IBOutlet weak var termsandconditions: UIView!
    @IBOutlet weak var deleteAccountBtn: UIView!
    @IBOutlet weak var logoutBtn: UIView!
    
 
    
    let aboutUs = AboutUsController()
    let disclaimer = DisclaimerOverlay()
    
    @IBOutlet weak var helpCenter: UIView!
    
    
    override func viewDidLoad() {
        
        if !Auth.auth().currentUser!.isAnonymous {
            name.text = UserData.data!.fullName ?? "Mind Motivations"
            email.text = UserData.data!.email ?? "support@mindmotivations.com"
        }
        
     
        
 
        
        notificationView.layer.cornerRadius = 8
        aboutUsView.layer.cornerRadius = 8
        privacyPolicyView.layer.cornerRadius = 8
        deleteAccountView.layer.cornerRadius = 8
        logoutView.layer.cornerRadius = 8
        
        termsAndConditionsView.layer.cornerRadius = 8
        disclaimerView.layer.cornerRadius = 8
        faqsView.layer.cornerRadius = 8
        helpCenterView.layer.cornerRadius = 8
        
        notificationBtn.isUserInteractionEnabled = true
        notificationBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notificationClicked)))
        
        aboutUsBtn.isUserInteractionEnabled = true
        aboutUsBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aboutUsClicked)))
        
        privacyPolicyBtn.isUserInteractionEnabled = true
        privacyPolicyBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privacyPolicyClicked)))
        
        termsandconditions.isUserInteractionEnabled = true
        termsandconditions.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsAndConditionsClicked)))
        
        faqBtn.isUserInteractionEnabled = true
        faqBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(faqsClicked)))
        
        deleteAccountBtn.isUserInteractionEnabled = true
        deleteAccountBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteAccountClicked)))
        
        helpCenter.isUserInteractionEnabled = true
        helpCenter.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(helpCentreClicked)))
        
        logoutBtn.isUserInteractionEnabled = true
        logoutBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logoutClicked)))
        
        disclaimerBtn.isUserInteractionEnabled = true
        disclaimerBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(disclaimerClicked)))
        
        
    }
    
    @objc func disclaimerClicked(){
        self.disclaimer.modalPresentationStyle = .custom
        self.disclaimer.transitioningDelegate = self
        self.present(self.disclaimer, animated: true, completion: nil)
    }
    
    @objc func helpCentreClicked(){
        if let url = URL(string: "mailto:mindmotivationsapp@gmail.com") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    }
    
    @objc func faqsClicked(){
        if let faqsPath = Bundle.main.path(forResource: "FAQS", ofType: "pdf")  {
            let dc = UIDocumentInteractionController(url: URL(fileURLWithPath: faqsPath))
            dc.delegate = self
            dc.presentPreview(animated: true)
        }
    }
    
    @objc func deleteAccountClicked(){
        let alert = UIAlertController(title: "DELETE ACCOUNT", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            
            if let user = Auth.auth().currentUser {
                
                self.ProgressHUDShow(text: "Account Deleting...")
                let userId = user.uid
                
                        Firestore.firestore().collection("Users").document(userId).delete { error in
                           
                            if error == nil {
                                user.delete { error in
                                    self.ProgressHUDHide()
                                    if error == nil {
                                        self.logout()
                                        
                                    }
                                    else {
                                        self.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
                                    }
    
                                
                                }
                                
                            }
                            else {
                       
                                self.showError(error!.localizedDescription)
                            }
                        }
                    
                }
            
            
        }))
        present(alert, animated: true)
    }
    
  
    
    @objc func privacyPolicyClicked(){
        if let privacyFilePath = Bundle.main.path(forResource: "Privacy Policy", ofType: "pdf")  {
            let dc = UIDocumentInteractionController(url: URL(fileURLWithPath: privacyFilePath))
            dc.delegate = self
            dc.presentPreview(animated: true)
        }
          
    }
    
    @objc func termsAndConditionsClicked(){
        if let termsAndConditionsFilePath = Bundle.main.path(forResource: "Terms And Conditions", ofType: "pdf")  {
            let dc = UIDocumentInteractionController(url: URL(fileURLWithPath: termsAndConditionsFilePath))
            dc.delegate = self
            dc.presentPreview(animated: true)
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self//or use return self.navigationController for fetching app navigation bar colour
    }

    @objc func aboutUsClicked(){
        self.aboutUs.modalPresentationStyle = .custom
        self.aboutUs.transitioningDelegate = self
        self.present(self.aboutUs, animated: true, completion: nil)
    }
    
    @objc func notificationClicked(){
        performSegue(withIdentifier: "settingsnotificationseg", sender: nil)
    }
    

    @objc func logoutClicked(){
        
        
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive,handler: { action in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        
    }
    
    
}


extension ProfileViewController : UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
    
        
        if let name =  presented.nibName {
            if name == "AboutUsController" {
                return AboutUsPresentationController(presentedViewController: presented, presenting: presenting)
            }
            else if name == "DisclaimerOverlay" {
                return DisclaimerPresentationController(presentedViewController: presented, presenting: presenting)
            }

        }

        return presentationController(forPresented: presented, presenting: presenting, source: source)
       
            
 
    }
    
    
    

}
