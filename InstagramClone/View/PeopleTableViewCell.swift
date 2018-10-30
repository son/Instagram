//
//  PeopleTableViewCell.swift
//  InstagramClone
//
//  Created by takeru on 2018/04/30.
//  Copyright © 2018年 takeru. All rights reserved.
//

import UIKit
protocol PeopleTableViewCellDelegate {
    func goProfileUserVC(userId: String)
}

class PeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var delegate: PeopleTableViewCellDelegate?
    
    var user: UserModel? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        nameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImg.jpeg"))
        }
        if user!.isFollowing! { // == true
            self.configureUnFollowButton()
        } else {
            self.configureFollowButton()
        }
    }
    
    func configureFollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        followButton.backgroundColor = UIColor(red: 69/255, green: 142/255, blue: 255/255, alpha: 1)
        self.followButton.setTitle("Follow", for: .normal)
        
        followButton.addTarget(self, action: #selector(self.followAction), for: .touchUpInside)
    }
    
    func configureUnFollowButton() {
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        
        followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        followButton.backgroundColor = UIColor.clear
        
        self.followButton.setTitle("Following", for: .normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: .touchUpInside)
    }
    
    @objc func followAction() {
        if user?.isFollowing == false {
            API.Follow.followAction(withUser: user!.id!)
            configureUnFollowButton()
            user?.isFollowing = true
        }
    }
    
    @objc func unFollowAction() {
        if user?.isFollowing == true {
            API.Follow.unFollowAction(withUser: user!.id!)
            configureFollowButton()
            user?.isFollowing = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.otherUserButton))
        nameLabel.addGestureRecognizer(tapGestureForNameLabel)
        nameLabel.isUserInteractionEnabled = true
    }
    
    @objc func otherUserButton() {
        if let id = user?.id {
            delegate?.goProfileUserVC(userId: id)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
