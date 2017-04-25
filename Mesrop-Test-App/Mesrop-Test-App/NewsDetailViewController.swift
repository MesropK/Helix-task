//
//  DetailViewController.swift
//  Mesrop-Test-App
//
//  Created by Mesrop Kareyan on 4/25/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController {

    @IBOutlet weak var newsImageView: UIImageView!
     @IBOutlet weak var newsWebView:  UIWebView!


    func configureView() {
        // Update the user interface for the detail item.
        if let news = self.newsItem {
            if let url = news.coverPhotoUrl {
                NetworkManager.shared.downloadImage(at: url, completion: { image  in
                    self.newsImageView.image = image
                })
            }
            if let body = news.body {
                newsWebView.loadHTMLString(body, baseURL: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var newsItem: NewsItemEntity? {
        didSet {
            // Update the view.
            if self.isViewLoaded {
                configureView()
            }
        }
    }


}

