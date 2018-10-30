//
//  NotificationAPI.swift
//  InstagramClone
//
//  Created by takeru on 2018/05/10.
//  Copyright © 2018年 takeru. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NotificationAPI {
    
    var REF_NOTIFICATION = Database.database().reference().child("notification")
    
    func observeNotification(withId id: String, completion: @escaping (NotificationModel) -> Void) {
        REF_NOTIFICATION.child(id).observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let newNotification = NotificationModel.transform(dict: dict, key: snapshot.key)
                completion(newNotification)
            }
        }
    }
}
