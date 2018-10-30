//
//  CameraViewController.swift
//  InstagramClone
//
//  Created by takeru on 2018/04/14.
//  Copyright © 2018年 takeru. All rights reserved.
//

import UIKit
import KRProgressHUD
import AVFoundation

class CameraViewController: UIViewController {
    
    var selectedImage: UIImage?
    var videoUrl: URL?

    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var captionTextView: UITextView!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var removeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhotoImage))
        photoImage.addGestureRecognizer(tapGesture)
        photoImage.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handlePost()
    }
    
    func handlePost() {
        if selectedImage != nil {
            self.shareButton.isEnabled = true
            self.removeButton.isEnabled = true
            self.shareButton.backgroundColor = UIColor.gray
        } else {
            self.shareButton.isEnabled = false
            self.removeButton.isEnabled = false
            self.shareButton.backgroundColor = UIColor.lightGray
        }
    }
    
    @objc func handleSelectPhotoImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image", "pubic.movie"]
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func shareButton(_ sender: Any) {
        KRProgressHUD.show(withMessage: "loading...")
        if let profileImage = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImage, 0.1) {
            let ratio = profileImage.size.width / profileImage.size.height
            HelperService.uploadDataToServer(data: imageData, videoUrl: self.videoUrl, ratio: ratio, caption: captionTextView.text!) {
                self.clean()
                self.tabBarController?.selectedIndex = 0
            }
        } else {
            KRProgressHUD.showError(withMessage: "Profile image can't be empty")
        }
    }
    
    @IBAction func remove(_ sender: Any) {
        clean()
        handlePost()
    }
    
    func clean() {
        self.captionTextView.text = ""
        self.photoImage.image = UIImage(named: "Placeholder-image.png")
        self.selectedImage = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filterSegue" {
            let filterVC = segue.destination as! FilterViewController
            filterVC.selectedImage = self.selectedImage
            filterVC.delegate = self
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info["UIImagePickerControllerMediaURL"] as? URL {
            if let thumbnailImage = self.thumbnailImageForFileUrl(videoUrl) {
                selectedImage = thumbnailImage
                photoImage.image = thumbnailImage
                self.videoUrl = videoUrl
            }
            dismiss(animated: true, completion: nil)
        }
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            photoImage.image = image
            dismiss(animated: true) {
                self.performSegue(withIdentifier: "filterSegue", sender: nil)
            }
        }
        
    }
    
    func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(6, 3), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print(error)
        }
        return nil
    }
}

extension CameraViewController: FilterViewControllerDelegate {
    
    func updatePhoto(image: UIImage) {
        self.photoImage.image = image
    }
}





