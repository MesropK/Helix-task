//
//  ShowImageViewController.swift
//  Mesrop-Test-App
//
//  Created by Mesrop Kareyan on 4/26/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit
import Haneke

class ShowImageViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    
    
    var galleryItem: GalleryItemEntity?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let galleryItem = galleryItem,
            let urlString = galleryItem.contentUrl {
            self.titleLabel.text = galleryItem.title
            self.title = galleryItem.title
            if let url = URL(string: urlString) {
                self.mainImageView.hnk_setImageFromURL(url)
            }
        }
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
