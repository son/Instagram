//
//  FollowAPI.swift
//  InstagramClone
//
//  Created by takeru on 2018/05/01.
//  Copyright © 2018年 takeru. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FollowAPI {
    
    var REF_FOLLOWERS = Database.database().reference().child("followers")
    
    var REF_FOLLOWING = Database.database().reference().child("following")
    
    func followAction(withUser id: String) {
        API.MyPosts.REF_MYPOSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    if let value = dict[key] as? [String: Any] {
                        let timestampPost = value["timestamp"] as! Int
                        Database.database().reference().child("feed").child(API.User.CURRENT_USER!.uid).child(key).setValue(["timestamp": timestampPost])
                    }
                }
            }
        }
        REF_FOLLOWERS.child(id).child(API.User.CURRENT_USER!.uid).setValue(true)
        REF_FOLLOWING.child(API.User.CURRENT_USER!.uid).child(id).setValue(true)
    }
    
    func unFollowAction(withUser id: String) {
        API.MyPosts.REF_MYPOSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(API.User.CURRENT_USER!.uid).child(key).removeValue()
                }
            }
        }
        REF_FOLLOWERS.child(id).child(API.User.CURRENT_USER!.uid).setValue(NSNull())
        REF_FOLLOWING.child(API.User.CURRENT_USER!.uid).child(id).setValue(NSNull())
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        REF_FOLLOWERS.child(userId).child(API.User.CURRENT_USER!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                completed(false)
            } else {
                completed(true)
            }
        }
    }
    
    func fetchCountFollowing(userId: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWING.child(userId).observe(.value) { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }
    }
    
    func fetchCountFollowers(userId: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWERS.child(userId).observe(.value) { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }
    }
}










