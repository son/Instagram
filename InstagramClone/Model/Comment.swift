//
//  Comment.swift
//  InstagramClone
//
//  Created by takeru on 2018/04/26.
//  Copyright © 2018年 takeru. All rights reserved.
//

import Foundation

class Comment {
    
    var commentText: String?
    var uid: String?
}

extension Comment {
    
    static func transformComment(dict: [String: Any]) -> Comment {
        let comment = Comment()
        comment.commentText = dict["commentText"] as? String
        comment.uid = dict["uid"] as? String
        return comment
    }    
}
