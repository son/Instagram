//
//  PhotoCollectionViewCell.swift
//  InstagramClone
//
//  Created by takeru on 2018/04/29.
//  Copyright © 2018年 takeru. All rights reserved.
//

import UIKit

protocol PhotoCollectionViewCellDelegate {
    func goDetailVC(postId: String)
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var delegate: PhotoCollectionViewCellDelegate?
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            photoImageView.sd_setImage(with: photoUrl)
        }
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.photoButton))
        photoImageView.addGestureRecognizer(tapGestureForPhoto)
        photoImageView.isUserInteractionEnabled = true
    }
    
    @objc func photoButton() {
        if let id = post?.id {
            delegate?.goDetailVC(postId: id)
        }
    }
}
