//
//  DetailViewController.swift
//  Mesrop-Test-App
//
//  Created by Mesrop Kareyan on 4/25/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit
import SKPhotoBrowser

class NewsDetailViewController: UIViewController {

    @IBOutlet weak var newsImageView:           UIImageView!
    @IBOutlet var      thumbnailImages:         [UIImageView]!
    @IBOutlet weak var galleryPlusImageView:    UIImageView!
    @IBOutlet weak var newsWebView:             UIWebView!
    @IBOutlet weak var titleLabel:              UILabel!
    @IBOutlet weak var categoryLabel:           UILabel!
    @IBOutlet weak var galleryItemsView:        UIView!

    func configureView() {
        // Update the user interface for the news item.
        if let news = self.newsItem {
            //news title ui
            titleLabel.text = news.title
            categoryLabel.text = "/" + news.category!
            //news main cover Image
            if let urlString = news.coverPhotoUrl {
                let url = URL(string: urlString)!
                self.newsImageView.hnk_setImageFromURL(url)
            }
            //news text content
            if let body = news.body {
                newsWebView.loadHTMLString(body, baseURL: nil)
            }
            //news thumbnail images
            guard let galleryItems = news.gallery, galleryItems.count > 0 else {
                galleryItemsView.isHidden = true
                return
            }
            //get all gallery items array and show max 3 items
            var galleryArray: Array<GalleryItemEntity> = Array(galleryItems) as! Array<GalleryItemEntity>
            var items = [GalleryItemEntity]()
            var itemsCount = 0
            while itemsCount < 3 && itemsCount < galleryArray.count {
                items.append(galleryArray[itemsCount])
                itemsCount += 1
            }
            // hide extra thumbnails container views
            for index in itemsCount..<3 {
                thumbnailImages[index].superview!.isHidden = true
            }
            //show images
            for (index, item ) in items.enumerated() {
                if let thumbnailUrlString = item.thumbnailUrl,
                        let  thumbnailUrl = URL(string: thumbnailUrlString) {
                        thumbnailImages[index].hnk_setImageFromURL(thumbnailUrl)
                    }
                }
            }
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }


    var newsItem: NewsItemEntity? {
        didSet {
            // Update the view.
            if self.isViewLoaded {
                configureView()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGallery",
            let galleryViewController = segue.destination as? GalleryViewControllerCollectionViewController,
            let galleryItems = newsItem?.gallery {
            galleryViewController.galleryItems = Array(galleryItems) as? [GalleryItemEntity]
        }
    }

    @IBAction func moreButtonTapped(_ sender: UITapGestureRecognizer) {
        showGallery()
    }
    
    func showGallery() {
        guard let news = newsItem,
            let galleryItems = news.gallery as? Set<GalleryItemEntity>  else {
                return
        }
        // 1. create URL Array
        var images = [SKPhoto]()
        for galleryItem in galleryItems {
            if let photoUrl = galleryItem.contentUrl {
                let photo = SKPhoto.photoWithImageURL(photoUrl)
                photo.shouldCachePhotoURLImage = false // you can use image cache by true(NSCache)
                images.append(photo)
            }
        }

        // 2. create PhotoBrowser Instance, and present.
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(0)
        //configure Browser
        browser.title = news.title
        present(browser, animated: true, completion: {})
    }

}

