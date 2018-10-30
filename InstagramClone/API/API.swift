//
//  API.swift
//  InstagramClone
//
//  Created by takeru on 2018/04/27.
//  Copyright © 2018年 takeru. All rights reserved.
//

import Foundation

struct API {
    
    static var User = UserAPI()
    static var Post = PostAPI()
    static var Comment = CommentAPI()
    static var Post_Comment = Post_CommentAPI()
    static var MyPosts = MyPostsAPI()
    static var Follow = FollowAPI()
    static var Feed = FeedAPI()
    static var HashTag = HashTagAPI()
    static var Notification = NotificationAPI()
}
