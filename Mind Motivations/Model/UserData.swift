//
//  UserData.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 13/10/22.
//
import UIKit


class UserData :  NSObject , Codable {
    
    var fullName : String?
    var email : String?
    var uid : String?
    var registredAt : Date?
    var regiType : String?
   

    
      private static var userData : UserData?
     
      static var data : UserData? {
          set(userData) {
              self.userData = userData
          }
          get {
              return userData
          }
      }


      override init() {
          
      }
}
