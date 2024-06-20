//
//  ViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 13/10/22.
//

import UIKit
import Firebase
import AuthenticationServices
import CryptoKit
import FBSDKCoreKit
import FBSDKLoginKit

fileprivate var currentNonce : String?

class SignInViewController: UIViewController {
    @IBOutlet weak var skipBtn: UIButton!
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var forgotPassword: UILabel!
    
    @IBOutlet weak var loginBtn: UIButton!

    @IBOutlet weak var loginWithGoogle: UIView!
    
    @IBOutlet weak var loginWithFacebook: UIView!
    @IBOutlet weak var signUpBtn: UILabel!
    @IBOutlet weak var signInWithApple: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProgressHUDShow(text: "")
        Firestore.firestore().collection("SkipButton").document("onHIkx1X8SjhHMv9qwxt").getDocument { snapshot, error in
            self.ProgressHUDHide()
            if let snapshot = snapshot, snapshot.exists {
                if let data = snapshot.data() , let isVISIBLE = data["visible"] as? Bool, isVISIBLE{
                    self.skipBtn.isHidden = false
                }
                else {
                    self.skipBtn.isHidden = true
                }
            }
            else {
                self.skipBtn.isHidden = true
            }
        }
        
        skipBtn.layer.cornerRadius = 8
        skipBtn.dropShadow()
        
        emailTF.layer.cornerRadius = 8
        passwordTF.layer.cornerRadius = 8
        
        emailTF.setLeftPaddingPoints(16)
        emailTF.setRightPaddingPoints(10)
        
        passwordTF.setLeftPaddingPoints(16)
        passwordTF.setRightPaddingPoints(10)
        
        emailTF.changePlaceholderColour()
        passwordTF.changePlaceholderColour()
        
        emailTF.delegate = self
        passwordTF.delegate = self
        
        emailTF.setLeftView(image: UIImage.init(named: "mail")!)
        passwordTF.setLeftView(image: UIImage.init(named: "padlock")!)
        
        
        loginBtn.layer.cornerRadius = 12
        
        loginWithGoogle.layer.cornerRadius = 8
        loginWithGoogle.addBorder()
        loginWithGoogle.isUserInteractionEnabled = true
        loginWithGoogle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginWithGoogleBtnClicked)))
        
        signInWithApple.layer.cornerRadius = 8
        signInWithApple.addBorder()
        signInWithApple.isUserInteractionEnabled = true
        signInWithApple.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginWithAppleBtnClicked)))
        
        loginWithFacebook.layer.cornerRadius = 8
        loginWithFacebook.addBorder()
        loginWithFacebook.isUserInteractionEnabled = true
        loginWithFacebook.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginWithFacebookClicked)))
        
        signUpBtn.isUserInteractionEnabled = true
        signUpBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoSignUpScreen)))
        forgotPassword.isUserInteractionEnabled = true
        forgotPassword.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(forgotPasswordClicked)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func forgotPasswordClicked() {
        let sEmail = emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sEmail == "" {
            showSnack(messages: "Enter Email Address")
        }
        else {
            ProgressHUDShow(text: "")
            Auth.auth().sendPasswordReset(withEmail: sEmail!) { error in
                self.ProgressHUDHide()
                if error == nil {
                    self.showMessage(title: "RESET PASSWORD", message: "We have sent reset password link on your mail address.", shouldDismiss: false)
                }
                else {
                    self.showError(error!.localizedDescription)
                }
            }
        }
    }


    @objc func hideKeyboard(){
        view.endEditing(true)
    }

    @IBAction func loginBtnClicked(_ sender: Any) {
        let sEmail = emailTF.text?.trimmingCharacters(in: .nonBaseCharacters)
        let sPassword = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sEmail == "" {
            showSnack(messages: "Enter Email Address")
        }
        else if sPassword == "" {
            showSnack(messages: "Enter Password")
        }
        else {
            ProgressHUDShow(text: "")
            Auth.auth().signIn(withEmail: sEmail!, password: sPassword!) { authResult, error in
                self.ProgressHUDHide()
                if error == nil {
                    
                    if Auth.auth().currentUser != nil {
                        if Auth.auth().currentUser?.uid == "LYV2GwFQSTc937U526aP4klO4X42" {
                            self.beRootScreen(mIdentifier: Constants.StroyBoard.adminTabBarViewController)
                            
                        }
                        else {
                            self.beRootScreen(mIdentifier: Constants.StroyBoard.welcome2ViewController)
                        }
                           
                      
                      
                    }
                }
                else {
                    self.showError(error!.localizedDescription)
                }
            }
        }
        
    }
    
    
    @IBAction func skipBtnClicked(_ sender: Any) {
        Auth.auth().signInAnonymously { result, error in
            self.beRootScreen(mIdentifier: Constants.StroyBoard.tabBarViewController)
        }
    }
    
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    

    
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        // authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
   
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    @objc func loginWithFacebookClicked(){
        self.loginFacebook()
    }

    
    @objc func loginWithGoogleBtnClicked() {
        self.loginWithGoogle()
    }
    
    @objc func loginWithAppleBtnClicked(){
     
        self.startSignInWithAppleFlow()
    }
    
    @objc func gotoSignUpScreen() {
        self.performSegue(withIdentifier: "signupseg", sender: nil)
    }
    
  

    func loginFacebook() {
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile","email"], from: self) { (result, error) in
            if (error == nil){
                
                let fbloginresult : LoginManagerLoginResult = result!
              // if user cancel the login
                if (result?.isCancelled)!{
                      return
                }
             
               
              if(fbloginresult.grantedPermissions.contains("email"))
              { if((AccessToken.current) != nil){
               
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                self.authWithFirebase(credential: credential,type: "facebook",displayName: "")
              }
                
              }
            
            }
            else {
                self.showError(error!.localizedDescription)
            }
        }
    
    }
}

extension SignInViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    

    
}
extension SignInViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            var displayName = "Darwinning"
            if let fullName = appleIDCredential.fullName {
                if let firstName = fullName.givenName {
                    displayName = firstName
                }
                if let lastName = fullName.familyName {
                    displayName = "\(displayName) \(lastName)"
                }
            }
            
            authWithFirebase(credential: credential, type: "apple",displayName: displayName)
            // User is signed in to Firebase with Apple.
            // ...
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        
        print("Sign in with Apple errored: \(error)")
    }
    
}
