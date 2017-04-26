//
//  GalleryViewControllerCollectionViewController.swift
//  Mesrop-Test-App
//
//  Created by Mesrop Kareyan on 4/26/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit
import Haneke
import SKPhotoBrowser

private let reuseIdentifier = "galleryItemCell"

class GalleryViewControllerCollectionViewController: UICollectionViewController {
    
    var galleryItems: [GalleryItemEntity]?
    weak var selectedItem: GalleryItemEntity?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage",
            let controller = segue.destination as? ShowImageViewController {
            controller.galleryItem = selectedItem
        }
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showGallery(fromIndex: indexPath.item)
    }
 

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return galleryItems?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GalleryItemCollectionViewCell
        if let galleryItem = galleryItems?[indexPath.item],
            let contentURLString = galleryItem.contentUrl,
            let contentUrl = URL(string: contentURLString){
            cell.imageView.hnk_setImageFromURL(contentUrl)
        }
        return cell
    }
    
    func showGallery(fromIndex index: Int) {
        guard let galleryItem = galleryItems?[index],
        let urlString = galleryItem.contentUrl
             else {
            return
        }
        // 1. create URL Array
        var images = [SKPhoto]()
        let photo = SKPhoto.photoWithImageURL(urlString)
        photo.shouldCachePhotoURLImage = false // you can use image cache by true(NSCache)
        images.append(photo)
        
        // 2. create PhotoBrowser Instance, and present.
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(0)
        present(browser, animated: true, completion: {})
    }

    // MARK: UICollectionViewDelegate
    

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */


    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        selectedItem = galleryItems?[indexPath.item]
        return true
    }


    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
