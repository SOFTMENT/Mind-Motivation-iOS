//
//  SignUpViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 13/10/22.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestoreSwift

class SignUpViewController : UIViewController {
    
   
    @IBOutlet weak var backBtn: UIView!
    @IBOutlet weak var fullNameTF: UITextField!
    
    @IBOutlet weak var emailTF: UITextField!
    
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UILabel!
    
    @IBOutlet weak var signUpBtn: UIButton!
    override func viewDidLoad() {
        
       
        fullNameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
       
        fullNameTF.setLeftPaddingPoints(16)
        fullNameTF.setRightPaddingPoints(10)
        
        emailTF.setLeftPaddingPoints(16)
        emailTF.setRightPaddingPoints(10)
        
        passwordTF.setLeftPaddingPoints(16)
        passwordTF.setRightPaddingPoints(10)
        
        fullNameTF.changePlaceholderColour()
        emailTF.changePlaceholderColour()
        passwordTF.changePlaceholderColour()
        
        fullNameTF.layer.cornerRadius = 8
        emailTF.layer.cornerRadius = 8
        passwordTF.layer.cornerRadius = 8
        
        fullNameTF.setLeftView(image: UIImage.init(named: "user")!)
        emailTF.setLeftView(image: UIImage.init(named: "mail")!)
        passwordTF.setLeftView(image: UIImage.init(named: "padlock")!)
        
        
        signUpBtn.layer.cornerRadius = 12
        
        loginBtn.isUserInteractionEnabled = true
        loginBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        backBtn.isUserInteractionEnabled = true
        backBtn.layer.cornerRadius = 8
        backBtn.addBorder()
        backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
    }
    
    
    @objc func backBtnClicked(){
        self.dismiss(animated: false)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        let sFullName = fullNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sEmail = emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sPassword = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sFullName == "" {
            showSnack(messages: "Enter Full Name")
        }
        else if sEmail == "" {
            showSnack(messages: "Enter Email")
        }
        else if sPassword  == "" {
            showSnack(messages: "Enter Password")
        }
        else {
            ProgressHUDShow(text: "Creating Account...")
            Auth.auth().createUser(withEmail: sEmail!, password: sPassword!) { result, error in
                self.ProgressHUDHide()
                if error == nil {
                    
                    let userData = UserData()
                    userData.fullName = sFullName
                    userData.email = sEmail
                    userData.uid = Auth.auth().currentUser!.uid
                    userData.registredAt = Date()
                    userData.regiType = "custom"
                    
                    self.addUserData(userData: userData)
                }
                else {
                    self.showError(error!.localizedDescription)
                }
            }
        }
        
    }
    
}

extension SignUpViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}
