//
//  HomeViewController.swift
//  InstagramClone
//
//  Created by takeru on 2018/04/13.
//  Copyright © 2018年 takeru. All rights reserved.
//

import UIKit
import SDWebImage
import KRProgressHUD

class HomeViewController: UIViewController {

    var posts = [Post]()
    var users = [UserModel]()
    fileprivate var isLoadingPost = false
    let refreshControl = UIRefreshControl()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
        activityIndicatorView.startAnimating()
        loadPosts()
    }
    
    @objc func refresh() {
        posts.removeAll()
        users.removeAll()
        loadPosts()
    }
    
    func loadPosts() {
        isLoadingPost = true
        API.Feed.getRecentFeed(withId: API.User.CURRENT_USER!.uid, start: posts.first?.timestamp, limit: 3  ) { (results) in
            // result = post + user
            if results.count > 0 {
                results.forEach({ (result) in
                    self.posts.append(result.0)
                    self.users.append(result.1)
                })
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.isLoadingPost = false
            self.activityIndicatorView.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
//    private func displayNewPosts(newPosts posts: [Post]) {
//        guard posts.count > 0 else {
//            return
//        }
//        var indexPaths:[IndexPath] = []
//        self.tableView.beginUpdates()
//        for post in 0...(posts.count - 1) {
//            let indexPath = IndexPath(row: post, section: 0)
//            indexPaths.append(indexPath)
//        }
//        self.tableView.insertRows(at: indexPaths, with: .none)
//        self.tableView.endUpdates()
//    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as! String
            commentVC.postId = postId
        }
        if segue.identifier == "homeToProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.isEmpty {
            return 0
        }
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeTableViewCell
        if posts.isEmpty {
            return UITableViewCell()
        }
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            guard !isLoadingPost else {
                return
            }
            isLoadingPost = true
            guard let lastPostTimestamp = self.posts.last?.timestamp else {
                isLoadingPost = false
                return
            }
            API.Feed.getOldFeed(withId: API.User.CURRENT_USER!.uid, start: lastPostTimestamp, limit: 5) { (results) in
                if results.count == 0 {
                    return
                }
                for result in results {
                    self.posts.append(result.0)
                    self.users.append(result.1)
                }
                self.tableView.reloadData()
                self.isLoadingPost = false
            }
        }
    }
}

extension HomeViewController: HomeTableViewCellDelegate {
    
    func goCommentVC(postId: String) {
        performSegue(withIdentifier: "commentSegue", sender: postId)
    }
    
    func goProfileUserVC(userId: String) {
        performSegue(withIdentifier: "homeToProfileSegue", sender: userId)
    }
}
