//
//  MyPostsAPI.swift
//  InstagramClone
//
//  Created by takeru on 2018/04/29.
//  Copyright © 2018年 takeru. All rights reserved.
//

import Foundation
import FirebaseDatabase

class MyPostsAPI {
    
    var REF_MYPOSTS = Database.database().reference().child("myPosts")

    func fetchMyPosts(userId: String, completion: @escaping (String) -> Void) {
        REF_MYPOSTS.child(userId).observe(.childAdded) { (snapshot) in
            completion(snapshot.key)
        }
    }
    
    func fetchCountMyPosts(userId: String, completion: @escaping (Int) -> Void) {
        REF_MYPOSTS.child(userId).observe(.value) { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }
    }
}
