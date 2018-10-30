//
//  CommentViewController.swift
//  InstagramClone
//
//  Created by takeru on 2018/04/26.
//  Copyright © 2018年 takeru. All rights reserved.
//

import UIKit
import KRProgressHUD

class CommentViewController: UIViewController {

    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var constraintToBottom: NSLayoutConstraint!
    
    var postId: String!
    var comments = [Comment]()
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Comment"
        tableView.dataSource = self
        tableView.estimatedRowHeight = 81
        tableView.rowHeight = UITableViewAutomaticDimension
        empty()
        handleTextField()
        loadComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = keyboardFrame!.height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.constraintToBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func loadComments() {
        API.Post_Comment.REF_POST_COMMENTS.child(self.postId).observe(.childAdded) { (snapshot) in
            API.Comment.observeComments(withPostId: snapshot.key, completion: { (comment) in
                self.fetchUser(uid: comment.uid!, completed: {
                    self.comments.append(comment)
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        API.User.observeUser(withId: uid) { (user) in
            self.users.append(user)
            completed()
        }
    }
    
    func handleTextField(){
        commentTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        
    }
    
    @objc func textFieldDidChange(){
        if let commentText = commentTextField.text, !commentText.isEmpty {
            sendButton.setTitleColor(UIColor.black, for: .normal)
            sendButton.isEnabled = true
            return
        }
        sendButton.setTitleColor(UIColor.lightGray, for: .normal)
        sendButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func sendButton(_ sender: Any) {
        let commentsRef = API.Comment.REF_COMMENTS
        let newCommentId = commentsRef.childByAutoId().key
        let newCommentRef = commentsRef.child(newCommentId)
        guard let currentUser = API.User.CURRENT_USER else {
            return
        }
        let currentUid = currentUser.uid
        newCommentRef.setValue(["uid": currentUid, "commentText": commentTextField.text!], withCompletionBlock: { (error, ref) in
            if error != nil {
                KRProgressHUD.showError(withMessage: "\(error!.localizedDescription)")
                return
            }
            let postCommentRef = API.Post_Comment.REF_POST_COMMENTS.child(self.postId).child(newCommentId)
            postCommentRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: "\(error!.localizedDescription)")
                    return
                }
            })
            self.empty()
            self.view.endEditing(true)
        })
    }
    
    func empty() {
        commentTextField.text = ""
        sendButton.isEnabled = false
        sendButton.setTitleColor(UIColor.lightGray, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentToProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
  
}
extension CommentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
        let comment = comments[indexPath.row]
        let user = users[indexPath.row]
        cell.comment = comment
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension CommentViewController: CommentTableViewCellDelegate {
    func goProfileUserVC(userId: String) {
        performSegue(withIdentifier: "commentToProfileSegue", sender: userId)
    }
}









