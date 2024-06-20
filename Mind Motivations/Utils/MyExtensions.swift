//
//  MyExtensions.swift
//  eventkreyol
//
//  Created by Vijay Rathore on 18/07/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestoreSwift
import Firebase
import MBProgressHUD
import TTGSnackbar
import GoogleSignIn
import FirebaseFirestore
import AVFoundation
import RevenueCat

extension UIView {
    
    func addBorder() {
        layer.borderWidth = 0.8
        layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
    }
    
}


extension UITextField {
 
      func setLeftView(image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 10, width: 22, height: 22)) // set your Own size
        iconView.image = image
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
        self.tintColor = .lightGray
      
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        
        self.rightView = paddingView
        self.rightViewMode = .always
        
    }
    
    func changePlaceholderColour()  {
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)])
    }
    
   
    
    /// set icon of 20x20 with left padding of 8px
    func setLeftIcons(icon: UIImage) {
        
        let padding = 8
        let size = 20
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        leftView = outerView
        leftViewMode = .always
    }
    
    
    
    
    /// set icon of 20x20 with left padding of 8px
    func setRightIcons(icon: UIImage) {
        
        let padding = 8
        let size = 12
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: -padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        rightView = outerView
        rightViewMode = .always
    }
    
}








extension Date {
    
    
    func removeTimeStamp() -> Date? {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
            return  nil
        }
        return date
    }
    
    func timeAgoSinceDate() -> String {
        
        // From Time
        let fromDate = self
        
        // To Time
        let toDate = Date()
        
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }
        
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }
        
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }
        
        return "a moment ago"
    }
}




extension UIViewController {

    
    func loginWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            authWithFirebase(credential: credential,type: "google", displayName: "")
            
        }
    }
    
    func showSnack(messages : String) {
        
        
        let snackbar = TTGSnackbar(message: messages, duration: .long)
        snackbar.messageLabel.textAlignment = .center
        snackbar.show()
    }
    
    func ProgressHUDShow(text : String) {
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.mode = .indeterminate
        loading.label.text =  text
        loading.label.font = UIFont(name: "RobotoCondensed-Regular", size: 11)
    }
    
    func ProgressHUDHide(){
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    

    

    func sentVerificationEmail(){
        self.ProgressHUDShow(text: "")
        Auth.auth().currentUser!.sendEmailVerification { error in
            self.ProgressHUDHide()
            if error == nil {
                self.showMessage(title: "Verify Your Email", message: "We have sent verification mail on your email address. Please verify your email address before Sign In.",shouldDismiss: true)
            }
            else {
                self.showError(error!.localizedDescription)
            }
        }
    }

    
    func addUserData(userData : UserData) {
        
        ProgressHUDShow(text: "")
     
        
        try?  Firestore.firestore().collection("Users").document(userData.uid ?? "123").setData(from: userData,completion: { error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil {
                self.showError(error!.localizedDescription)
            }
            else {
                self.beRootScreen(mIdentifier: Constants.StroyBoard.welcome2ViewController)
              
            }
           
        })
        

                                                                                                                                        
           
    }
    

    

    
    func membershipDaysLeft(currentDate : Date, expireDate : Date) -> Int {
        
        
        
        return Calendar.current.dateComponents([.day], from: currentDate, to: expireDate).day ?? 0
        
        
    }
    
    
    func checkMembershipStatus(currentDate : Date, expireDate : Date) -> Bool{
        
   if currentDate < expireDate  {
            
            return true
            
        }
        return false
    }
    

    
    func getUserData(uid : String, showProgress : Bool)  {
        

        
        if showProgress {
            ProgressHUDShow(text: "")
        }
        
        Firestore.firestore().collection("Users").document(uid).getDocument { (snapshot, error) in
            
            
            if error != nil {
                if showProgress {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                self.showError(error!.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, snapshot.exists {
                        
    
                        if let user = try? snapshot.data(as: UserData.self) {
                            UserData.data = user
                            
                       
                            
                            let seconds = 2.0
                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                
                                if user.uid == "5ITqes4XZ2XvxvfqsPlpulI85fr1" {
                                    Constants.membershipType = "YEARLY"
                                    self.beRootScreen(mIdentifier: Constants.StroyBoard.tabBarViewController)
                                }
                                else {
                                    Purchases.shared.getCustomerInfo { (customerInfo, error) in
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
                                       
                                        else {
                                            
                                            self.beRootScreen(mIdentifier: Constants.StroyBoard.membershipViewController)
                                        }
                                    }
                                }
                                
                                  
                            }
                          
                       
                        }
                        
                   
                    
                }
                else {
                    DispatchQueue.main.async {
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
                    }
                    
                }
                
                
                
                
            }
        }
    }
    




func navigateToAnotherScreen(mIdentifier : String)  {
    
    let destinationVC = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
    destinationVC.modalPresentationStyle = .fullScreen
    present(destinationVC, animated: true) {
        
    }
}

func myPerformSegue(mIdentifier : String)  {
    performSegue(withIdentifier: mIdentifier, sender: nil)
    
}

func getViewControllerUsingIdentifier(mIdentifier : String) -> UIViewController{
    
    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)

    switch mIdentifier {
    case Constants.StroyBoard.signInViewController:
        return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? SignInViewController)!
        
    case Constants.StroyBoard.tabBarViewController :
        return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? UITabBarController )!
        
    case Constants.StroyBoard.adminTabBarViewController :
        return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? UITabBarController)!
        
    case Constants.StroyBoard.membershipViewController :
        return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? MembershipViewController)!
        
    case Constants.StroyBoard.welcome2ViewController :
        return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? Welcome2Screen )!
        
        

    default:
        return (mainStoryboard.instantiateViewController(identifier: Constants.StroyBoard.signInViewController) as? SignInViewController)!
    }
}

func beRootScreen(mIdentifier : String) {
    
    guard let window = self.view.window else {
        self.view.window?.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
        self.view.window?.makeKeyAndVisible()
        return
    }
    
    window.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
    window.makeKeyAndVisible()
    UIView.transition(with: window,
                      duration: 1.6,
                      options: .transitionCrossDissolve,
                      animations: nil,
                      completion: nil)
    
}
    
    func convertSecondstoMinAndSec(totalSeconds : Int) -> String{
     
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%02i : %02i", minutes, seconds)

    }

func convertDateToMonthFormater(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "MMMM"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}


func convertDateAndTimeFormater(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd-MMM-yyyy hh:mm a"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

func convertDateFormaterWithoutDash(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd MMM yyyy"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

func convertDateFormater(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd-MMM-yyyy"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

func convertDateFormaterWithSlash(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd/MM/yy"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

func convertDateForHomePage(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "EEEE, dd MMMM"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}
func convertDateForVoucher(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "E, MMM dd  yyyy • hh:mm a"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

func convertDateForTicket(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "E,MMM dd, yyyy hh:mm a"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}



func convertDateIntoTimeForRecurringVoucher(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "hh:mm a"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return "\(df.string(from: date))"
    
    
}



func convertDateIntoMonthAndYearForRecurringVoucher(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "MMM • yyyy"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return "\(df.string(from: date))"
    
}

func convertDateIntoDayForRecurringVoucher(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "EEEE"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return "\(df.string(from: date))"
    
}

func convertDateIntoDayDigitForRecurringVoucher(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "d"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return "\(df.string(from: date))"
    
}

func convertDateForShowTicket(_ date: Date, endDate :Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "E,dd"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    let s = "\(df.string(from: date))-\(df.string(from: endDate))"
    df.dateFormat = "MMM yyyy"
    return "\(s) \(df.string(from: date))"
}

func convertTimeFormater(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "hh:mm a"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

    func addFav(by musicId : String, catId : String, albumId : String, uid : String,completion : @escaping (Bool) -> Void)  {
        let favModel = FavouriteModel()
        favModel.albumId = albumId
        favModel.musicId = musicId
        favModel.uid = uid
        favModel.catId = catId
        favModel.createDate = Date()
        
        try? Firestore.firestore().collection("Users").document(uid).collection("Favorites").document(musicId).setData(from: favModel) { error in
            if error == nil {
                completion(true)
            }
            else {
                completion(false)
            }
        }

    }
    
    func deleteFav(by musicId : String, uid : String,completion : @escaping (Bool) -> Void)  {
        
        Firestore.firestore().collection("Users").document(uid).collection("Favorites").document(musicId).delete { error in
            if error == nil {
                completion(true)
            }
            else {
                completion(false)
            }
        }
        
    }
    
    public func checkFavoritesStatus(uid : String, musicId : String,completion : @escaping (Bool) -> Void){
        
        
        let docRef = Firestore.firestore().collection("Users").document(uid).collection("Favorites").document(musicId)
        
        docRef.getDocument { (document, error) in
            if error == nil {
                if let document  = document {
                    if document.exists {
                        
                        completion(true)
                        
                    }
                    else{
                        completion(false)
                    }
                    
                }
                else {
                    completion(false)
                }
            }
        }
        
        
    }

func showError(_ message : String) {
    let alert = UIAlertController(title: "ERROR", message: message, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
    
    alert.addAction(okAction)
    
    self.present(alert, animated: true, completion: nil)
    
}

func showMessage(title : String,message : String, shouldDismiss : Bool = false) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "Ok",style: .default) { action in
        if shouldDismiss {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
    
}


func authWithFirebase(credential : AuthCredential, type : String,displayName : String) {
    
    ProgressHUDShow(text: "")
    
    Auth.auth().signIn(with: credential) { (authResult, error) in
        MBProgressHUD.hide(for: self.view, animated: true)
        if error != nil {
            
            self.showError(error!.localizedDescription)
        }
        else {
            let user = authResult!.user
            let ref =  Firestore.firestore().collection("Users").document(user.uid)
            ref.getDocument { (snapshot, error) in
                if error != nil {
                    self.showError(error!.localizedDescription)
                }
                else {
                    if let doc = snapshot {
                        if doc.exists {
                            self.beRootScreen(mIdentifier: Constants.StroyBoard.welcome2ViewController)
                            
                        }
                        else {
                            
                         
                            var emailId = ""
                            let provider =  user.providerData
                            var name = ""
                            for firUserInfo in provider {
                                if let email = firUserInfo.email {
                                    emailId = email
                                }
                            }
                            
                            if type == "apple" {
                                name = displayName
                            }
                            else {
                                name = user.displayName!.capitalized
                            }
                            
                          
                            
                            let userData = UserData()
                            userData.fullName = name
                            userData.email = emailId
                            userData.uid = user.uid
                            userData.registredAt = user.metadata.creationDate ?? Date()
                            userData.regiType = type
                          
                            self.addUserData(userData: userData)
                        }
                    }
                    
                }
            }
            
        }
        
    }
}


public func logout(){
    do {
        try Auth.auth().signOut()
        self.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
    }
    catch {
        self.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
    }
}

}






extension UIImageView {
    func makeRounded() {
        
        //self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        // self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        
    }
    
    
    
    
}



extension UIView {
    
    func smoothShadow(){
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 5
        //        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0 , height: 1.8)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: bounds.maxY - layer.shadowRadius,
                                                     width: bounds.width,
                                                     height: layer.shadowRadius)).cgPath
    }
    
    func installBlurEffect(isTop : Bool) {
        self.backgroundColor = UIColor.clear
        var blurFrame = self.bounds
        
        if isTop {
            var statusBarHeight : CGFloat = 0.0
            if #available(iOS 13.0, *) {
                if let window = UIApplication.shared.currentUIWindow() {
                    statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                }
              
            } else {
                statusBarHeight = UIApplication.shared.statusBarFrame.height
            }
            
            blurFrame.size.height += statusBarHeight
            blurFrame.origin.y -= statusBarHeight
            
        }
        else {
            if let window = UIApplication.shared.currentUIWindow() {
                let bottomPadding = window.safeAreaInsets.bottom
                blurFrame.size.height += bottomPadding
            }
          
           
            //  blurFrame.origin.y += bottomPadding
        }
        let blur = UIBlurEffect(style:.light)
        let visualeffect = UIVisualEffectView(effect: blur)
        visualeffect.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 0.7)
        visualeffect.frame = blurFrame
        self.addSubview(visualeffect)
    }
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = .zero
        layer.shadowRadius = 2
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
    
        layer.mask = mask
        
        
        
    }
}


extension Date {
    public func setTime(hour: Int, min: Int, timeZoneAbbrev: String = "UTC") -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: self)
        
        components.timeZone = TimeZone(abbreviation: timeZoneAbbrev)
        components.hour = hour
        components.minute = min
        
        return cal.date(from: components)
    }
}

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}


extension URL {
    static let timeIP = URL(string: "http://worldtimeapi.org/api/ip")!
    static func asyncTime(completion: @escaping ((Date?, TimeZone?, Error?)-> Void)) {
        URLSession.shared.dataTask(with: .timeIP) { data, response, error in
            guard let data = data else {
                completion(nil, nil, error)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let root = try decoder.decode(Root.self, from: data)
                completion(root.unixtime, TimeZone(identifier: root.timezone), nil)
            } catch {
                completion(nil, nil, error)
            }
        }.resume()
    }
}
public extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
        
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
