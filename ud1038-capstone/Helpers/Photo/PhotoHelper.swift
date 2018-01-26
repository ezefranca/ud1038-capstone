//
//  PhotoHelper.swift
//  ud1038-capstone
//
//  Created by Ezequiel on 11/11/17.
//  Copyright © 2017 Ezequiel. All rights reserved.
//

import Foundation
import UIKit

public protocol UIImageSeletable : class {
    func photoSelected(photo:UIImage?, error:Error?)
}

class UIImageSelecterController : UIViewController {
    
    let imagePickerController = UIImagePickerController()
    private var delegate: UIImageSeletable
    private let error:Error = NSError(domain: "Camera isn't avaliable", code: 0, userInfo: nil)
    
    init(_ delegate:UIImageSeletable) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        self.imagePickerController.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func takePhoto() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
        imagePickerController.sourceType = .camera
        self.present(imagePickerController, animated: true, completion: nil)
        //self.delegate.photoSelected(photo: self.imagePickerController, error: nil)
    } else {
        self.delegate.photoSelected(photo: nil, error: self.error)
    }
}

    func selectPhoto() {
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
}

extension UIImageSelecterController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imageSelected = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.delegate.photoSelected(photo: imageSelected, error: nil)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.delegate.photoSelected(photo: nil, error: self.error)
        dismiss(animated: true, completion: nil)
    }
}
