//
//  DetailViewController.swift
//  InstagramClone
//
//  Created by takeru on 2018/05/05.
//  Copyright © 2018年 takeru. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var postId = ""
    var post = Post()
    var user = UserModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        loadPost()
    }
    
    func loadPost() {
        API.Post.observePost(withId: postId) { (post) in
            guard let postUid = post.uid else {
                return
            }
            self.fetchUser(uid: postUid, completed: {
                self.post = post
                self.tableView.reloadData()
            })
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        API.User.observeUser(withId: uid) { (user) in
            self.user = user
            completed()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToCommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        if segue.identifier == "detailToProfileUserSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension DetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeTableViewCell
        
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension DetailViewController: HomeTableViewCellDelegate {
    
    func goCommentVC(postId: String) {
        performSegue(withIdentifier: "detailToCommentSegue", sender: postId)
    }
    
    func goProfileUserVC(userId: String) {
        performSegue(withIdentifier: "detailToProfileUserSegue", sender: userId)
    }
}









