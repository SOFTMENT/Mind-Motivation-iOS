//
//  NotificationModel.swift
//  Mind Motivations
//
//  Created by Vijay Rathore on 11/11/22.
//

import UIKit

class NotificationModel: NSObject, Codable {
  
    var title : String?
    var message : String?
    var notificationTime : Date?
    var notificationId : String?
}
