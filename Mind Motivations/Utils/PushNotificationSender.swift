//
//  PushNotificationSender.swift
//  Darwinning
//
//  Created by Apple on 10/12/21.
//

import UIKit

class PushNotificationSender {
    
    
    func sendPushNotificationToTopic(title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        
        let paramString: [String : Any] = ["to" : "/topics/darwinning",
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAqBzSPAk:APA91bEGVz80gPuqdqNp0CzMZ5tdmRui4XFfSj6bPDnQ9AStQM-NhkRHeCNXrx8USkxdb97U9BLWv8U2Ri1UITA-TID3RPc4BXYne5nmF3GeB9p4XkbiIVjIQdo7G7alXkBK9hpEAI5T", forHTTPHeaderField: "Authorization")
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                        
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    func sendPushNotificationToAdmin(title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        
        let paramString: [String : Any] = ["to" : "/topics/admin",
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAqBzSPAk:APA91bEGVz80gPuqdqNp0CzMZ5tdmRui4XFfSj6bPDnQ9AStQM-NhkRHeCNXrx8USkxdb97U9BLWv8U2Ri1UITA-TID3RPc4BXYne5nmF3GeB9p4XkbiIVjIQdo7G7alXkBK9hpEAI5T", forHTTPHeaderField: "Authorization")
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                        
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
