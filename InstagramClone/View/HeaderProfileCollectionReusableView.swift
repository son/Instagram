//
//  HeaderProfileCollectionReusableView.swift
//  InstagramClone
//
//  Created by takeru on 2018/04/29.
//  Copyright © 2018年 takeru. All rights reserved.
//

import UIKit

protocol HeaderProfileCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: UserModel)
}

protocol HeaderProfileCollectionReusableViewDelegateSwitchSettingVC {
    func goSettingVC()
}

class HeaderProfileCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myPostsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var delegate: HeaderProfileCollectionReusableViewDelegate?
    var delegate2: HeaderProfileCollectionReusableViewDelegateSwitchSettingVC?
    
    var user: UserModel? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
    }
    
    func updateView() {
        self.nameLabel.text = user!.username
        if let photoUrlString = user!.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            self.profileImageView.sd_setImage(with: photoUrl)
        }
        API.MyPosts.fetchCountMyPosts(userId: user!.id!) { (count) in
            self.myPostsCountLabel.text = "\(count)"
        }
        API.Follow.fetchCountFollowing(userId: user!.id!) { (count) in
            self.followingCountLabel.text = "\(count)"
        }
        API.Follow.fetchCountFollowers(userId: user!.id!) { (count) in
            self.followerCountLabel.text = "\(count)"
        }
        if user?.id == API.User.CURRENT_USER?.uid {
            followButton.setTitle("Edit Profile", for: .normal)
            followButton.addTarget(self, action: #selector(self.goSettingVC), for: .touchUpInside)
        } else {
            updateStateFollowButton()
        }
    }
    
    func clear() {
        self.nameLabel.text = ""
        self.myPostsCountLabel.text = ""
        self.followingCountLabel.text = ""
        self.followerCountLabel.text = ""
    }
    
    @objc func goSettingVC() {
        delegate2?.goSettingVC()
    }
    
    func updateStateFollowButton() {
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
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
    @objc func unFollowAction() {
        if user?.isFollowing == true {
            API.Follow.unFollowAction(withUser: user!.id!)
            configureFollowButton()
            user?.isFollowing = false
            delegate?.updateFollowButton(forUser: user!)
        }
    }

}
