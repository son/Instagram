//
//  ActivityTableViewCell.swift
//  InstagramClone
//
//  Created by takeru on 2018/05/10.
//  Copyright © 2018年 takeru. All rights reserved.
//

import UIKit

protocol ActivityTableViewCellDelegate {
    func goDetailVC(postId: String)
    //func goProfileVC(userId: String)
}

class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    
    var delegate: ActivityTableViewCellDelegate?
    
    var notification: NotificationModel? {
        didSet {
            updateView()
        }
    }
    
    var user: UserModel? {
        didSet {
            setupUserInfo()
        }
    }
    
    func updateView() {
        switch notification?.type {
        case "feed":
            descriptionLabel.text = "added a new post"
            let postId = notification!.objectId!
            API.Post.observePost(withId: postId) { (post) in
                if let photoUrlString = post.photoUrl {
                    let photoUrl = URL(string: photoUrlString)
                    self.photoImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg.jpeg"))
                }
            }
        default:
            print("")
        }
        if let timestamp = notification?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            var timeText = ""
            if diff.second! <= 0 {
                timeText = "now"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = "\(diff.second!) s"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = "\(diff.minute!) m"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = "\(diff.hour!) h"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = "\(diff.day!) d"
            }
            if diff.weekOfMonth! > 0 {
                timeText = "\(diff.second!) w"
            }
            timeLabel.text = timeText
            let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.cellButton))
            addGestureRecognizer(tapGestureForPhoto)
            isUserInteractionEnabled = true
        }
    }
    
    @objc func cellButton() {
        if let id = notification?.objectId {
            delegate?.goDetailVC(postId: id)
        }
    }
    
    func setupUserInfo() {
        nameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg.jpeg"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
