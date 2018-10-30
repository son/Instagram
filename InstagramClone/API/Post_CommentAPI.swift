//
//  Post_CommentAPI.swift
//  InstagramClone
//
//  Created by takeru on 2018/04/27.
//  Copyright © 2018年 takeru. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Post_CommentAPI {
    
    var REF_POST_COMMENTS = Database.database().reference().child("post-comments")
    
//    func observeComments(withPostId id: String, completion: @escaping (Comment) -> Void) {
//        REF_POST_COMMENTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
//            if let dict = snapshot.value as? [String: Any] {
//                let newComment = Comment.transformComment(dict: dict)
//                completion(newComment)
//            }
//        }
//    }
}
