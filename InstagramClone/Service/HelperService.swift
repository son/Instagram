//
//  HelperService.swift
//  InstagramClone
//
//  Created by takeru on 2018/04/30.
//  Copyright © 2018年 takeru. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import KRProgressHUD

class HelperService {
    
    static func uploadDataToServer(data: Data, videoUrl: URL? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void) {
        if let videoUrl = videoUrl {
            self.uploadVideoToFirebaseStorage(videoUrl: videoUrl, onSuccess: { (videoUrl) in
                uploadImageToFirebaseStorage(data: data, onSuccess: { (thumbnailImageUrl) in
                    sendDataToDatabase(photoUrl: thumbnailImageUrl, videoUrl: videoUrl, ratio: ratio, caption: caption, onSuccess: onSuccess)
                })
            })
            //self.senddatatodatabase
        } else {
            uploadImageToFirebaseStorage(data: data) { (photoUrl) in
                self.sendDataToDatabase(photoUrl: photoUrl, ratio: ratio, caption: caption, onSuccess: onSuccess)
            }
        }
    }
    
    static func uploadVideoToFirebaseStorage(videoUrl: URL, onSuccess: @escaping (_ videoUrl: String) -> Void) {
        let videoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("posts").child(videoIdString)
        storageRef.putFile(from: videoUrl, metadata: nil) { (metadata, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
                return
            }
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                onSuccess(videoUrl)
            }
        }
    }
    
    static func uploadImageToFirebaseStorage(data: Data, onSuccess: @escaping (_ imageUrl: String) -> Void) {
        let photoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("posts").child(photoIdString)
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
                return
            }
            if let photoUrl = metadata?.downloadURL()?.absoluteString {
                onSuccess(photoUrl)
            }
            
        }
    }
    
    static func sendDataToDatabase(photoUrl: String, videoUrl: String? = nil, ratio: CGFloat, caption: String, onSuccess: @escaping () -> Void) {
        let newPostId = API.Post.REF_POSTS.childByAutoId().key
        let newPostRef = API.Post.REF_POSTS.child(newPostId)
        guard let currentUser = API.User.CURRENT_USER else {
            return
        }
        let currentUserId = currentUser.uid
//        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
//        for var word in words {
//            if word.hasPrefix("#") {
//                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
//                let newHashTagRef = API.HashTag.REF_HASHTAG.child(word.lowercased())
//                newHashTagRef.updateChildValues([newPostId: true])
//            }
//        }
        let timestamp = Int(Date().timeIntervalSince1970)
        var dict = ["uid": currentUserId ,"photoUrl": photoUrl, "caption": caption, "likeCount": 0, "ratio": ratio, "timestamp": timestamp] as [String : Any]
        if let videoUrl = videoUrl {
            dict["videoUrl"] = videoUrl
        }
        newPostRef.setValue(dict) { (error, ref) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
                return
            }
            //ここがよく分からん⬇︎
            API.Feed.REF_FEED.child(API.User.CURRENT_USER!.uid).child(newPostId).setValue(["timestamp": timestamp])
            API.Follow.REF_FOLLOWERS.child(API.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: { snapshot in
                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraySnapshot.forEach({ (child) in
                    API.Feed.REF_FEED.child(child.key).child(newPostId).setValue(["timestamp": timestamp])
                    let newNotificationId = API.Notification.REF_NOTIFICATION.child(child.key).childByAutoId().key
                    let newNotificationReference = API.Notification.REF_NOTIFICATION.child(child.key).child(newNotificationId)
                    newNotificationReference.setValue(["from": API.User.CURRENT_USER!.uid, "type": "feed", "objectId": newPostId, "timestamp": timestamp])
                })
            })
            let myPostRef = API.MyPosts.REF_MYPOSTS.child(currentUserId).child(newPostId)
            myPostRef.setValue(["timestamp": timestamp], withCompletionBlock: { (error, ref) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: error!.localizedDescription)
                    return
                }
            })
            KRProgressHUD.showSuccess(withMessage: "Success")
            onSuccess()
        }
    }
}
