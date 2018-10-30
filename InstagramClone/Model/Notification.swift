//
//  Notification.swift
//  InstagramClone
//
//  Created by takeru on 2018/05/10.
//  Copyright © 2018年 takeru. All rights reserved.
//

import Foundation
import FirebaseAuth

class NotificationModel {
    
    var from: String?
    var objectId: String?
    var type: String?
    var timestamp: Int?
    var id: String?
}

extension NotificationModel {
    
    static func transform(dict: [String: Any], key: String) -> NotificationModel {
        let notification = NotificationModel()
        notification.from = dict["from"] as? String
        notification.objectId = dict["objectId"] as? String
        notification.type = dict["type"] as? String
        notification.timestamp = dict["timestamp"] as? Int
        notification.id = key

        return notification
    }
}
