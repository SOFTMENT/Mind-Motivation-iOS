//
//  TabBarViewController.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 13/10/22.
//

import UIKit


class TabBarViewController : UITabBarController, UITabBarControllerDelegate {
  
    var tabBarItems = UITabBarItem()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate  = self

        let selectedImage1 = UIImage(named: "lotus-flower")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage1 = UIImage(named: "lotus-flower-2")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![0]
        tabBarItems.image = deSelectedImage1
        tabBarItems.selectedImage = selectedImage1
        
        let selectedImage2 = UIImage(named: "radio-waves-5")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage2 = UIImage(named: "radio-waves-6")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![1]
        tabBarItems.image = deSelectedImage2
        tabBarItems.selectedImage = selectedImage2
        
        let selectedImage3 = UIImage(named: "favorite")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage3 = UIImage(named: "favorite-2")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![2]
        tabBarItems.image = deSelectedImage3
        tabBarItems.selectedImage = selectedImage3
        
        
        let selectedImage4 = UIImage(named: "user-7")?.withRenderingMode(.alwaysOriginal)
        let deSelectedImage4 = UIImage(named: "user-8")?.withRenderingMode(.alwaysOriginal)
        tabBarItems = self.tabBar.items![3]
        tabBarItems.image = deSelectedImage4
        tabBarItems.selectedImage = selectedImage4
        
    
        selectedIndex = 1
        
        let selectedColor   = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        let unselectedColor = UIColor(red: 165/255.0, green:165/255.0, blue:165/255.0, alpha: 1)
 
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: unselectedColor], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedColor], for: .selected)
     
        

    }
   
    


    
}


