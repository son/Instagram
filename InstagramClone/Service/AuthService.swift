//
//  AuthService.swift
//  InstagramClone
//
//  Created by takeru on 2018/04/15.
//  Copyright © 2018年 takeru. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class AuthService {

    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                onError(error?.localizedDescription)
                return
            }
            onSuccess()
        })
    }
    
    static func signUp(username: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error: Error?) in
            if error != nil {
                onError(error?.localizedDescription)
                return
            }
            let uid = user?.uid
            //Storage
            let storageRef = Storage.storage().reference().child("profileimage").child(uid!)
            storageRef.putData(imageData, metadata: nil, completion: { (metaData, error) in
                if error != nil {
                    return
                }
                let profileImageUrl = metaData?.downloadURL()?.absoluteString
                self.setUserInfomation(profileimageurl: profileImageUrl!, username: username, email: email, uid: uid!, onSuccess: onSuccess)
            })
        })
    }
    
    static func setUserInfomation(profileimageurl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        //RDB
        let ref = Database.database().reference()
        let usersRef = ref.child("users")
        let newUserRef = usersRef.child(uid)
        newUserRef.setValue(["username": username,
                             "username_lowercase": username.lowercased(),
                             "email": email,
                             "profileImageUrl": profileimageurl])
        onSuccess()
    }
    
    static func updateUserInfo(username: String, email: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        API.User.CURRENT_USER?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError(error?.localizedDescription)
            } else {
                let uid = API.User.CURRENT_USER?.uid
                //Storage
                let storageRef = Storage.storage().reference().child("profileimage").child(uid!)
                storageRef.putData(imageData, metadata: nil, completion: { (metaData, error) in
                    if error != nil {
                        return
                    }
                    let profileImageUrl = metaData?.downloadURL()?.absoluteString
                    self.updateDatabase(profileimageurl: profileImageUrl!, username: username, email: email, onSuccess: onSuccess, onError: onError)
                })
            }
        })
    }
    
    static func updateDatabase(profileimageurl: String, username: String, email: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let dict = ["username": username,
                     "username_lowercase": username.lowercased(),
                     "email": email,
                     "profileImageUrl": profileimageurl]
        API.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                onError(error?.localizedDescription)
            } else {
                onSuccess()
            }
        })
    }
    
    static func logOut(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        do {
            try Auth.auth().signOut()
            onSuccess()
        } catch let logOutError {
            onError(logOutError.localizedDescription)
        }
    }
}
