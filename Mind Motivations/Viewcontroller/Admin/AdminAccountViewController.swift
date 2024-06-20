//
//  AdminAccountViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 01/12/22.
//

import UIKit

class AdminAccountViewController : UIViewController {
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var logoutView: UIView!
    
    @IBOutlet weak var logoutBtn: UIView!
    @IBOutlet weak var notificationBtn: UIView!
    override func viewDidLoad() {
        
        profileView.layer.cornerRadius = 8
        notificationView.layer.cornerRadius = 8
        logoutView.layer.cornerRadius = 8
        
        logoutBtn.isUserInteractionEnabled = true
        logoutBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logoutClicked)))
        
        
        notificationBtn.isUserInteractionEnabled = true
        notificationBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notificationClicked)))
    }
    @objc func logoutClicked(){
        
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive,handler: { action in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        
    }
    @objc func notificationClicked(){
      
    }
    
}
