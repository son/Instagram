//
//  ActivityViewController.swift
//  InstagramClone
//
//  Created by takeru on 2018/04/14.
//  Copyright © 2018年 takeru. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notifications = [NotificationModel]()
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadNotifications()
    }
    
    func loadNotifications() {
        guard let currentUser = API.User.CURRENT_USER else {
            return
        }
        API.Notification.observeNotification(withId: currentUser.uid) { (notification) in
            guard let uid = notification.from else {
                return
            }
            self.fetchUser(uid: uid, completed: {
                self.notifications.insert(notification, at: 0)
                self.tableView.reloadData()
            })
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        API.User.observeUser(withId: uid) { (user) in
            self.users.insert(user, at: 0)
            completed()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "activityToDetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postId = sender as! String
            detailVC.postId = postId
        }
    }
}
extension ActivityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        let notification = notifications[indexPath.row]
        let user = users[indexPath.row]
        cell.notification = notification
        cell.user = user
        cell.delegate = self
        return cell
    }
}

extension ActivityViewController: ActivityTableViewCellDelegate {
    
    func goDetailVC(postId: String) {
        performSegue(withIdentifier: "activityToDetailSegue", sender: postId)
    }
}
