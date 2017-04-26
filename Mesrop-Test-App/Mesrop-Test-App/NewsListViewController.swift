//
//  NewsListViewController
//  Mesrop-Test-App
//
//  Created by Mesrop Kareyan on 4/25/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit
import CoreData
import Haneke

class NewsListViewController: UITableViewController {

    var detailViewController: NewsDetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var _fetchedResultsController: NSFetchedResultsController<NewsItemEntity>? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? NewsDetailViewController
        }
        NetworkManager.shared.getAllNews { result in
            switch result {
            case .fail(with: let error):
                self.showAlert(for: error)
            case .success(with: let data):
                let news = data as! [NewsItem]
                CoreDataManager.shared.saveNews(items: news)
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.tableView.reloadData()
    }

    func showAlert(for error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }


    func insertNewNewsObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newItem = NewsItemEntity(context: context)
             
        // If appropriate, configure the new managed object.
        newItem.date = NSDate()

        // Save the context.
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let newsObject = fetchedResultsController.object(at: indexPath)
                CoreDataManager.shared.makeNewsRead(news: newsObject)
                let controller = (segue.destination as! UINavigationController).topViewController as! NewsDetailViewController
                controller.newsItem = newsObject
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

// MARK: - Table View

extension NewsListViewController  {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let newsItem = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withNews: newsItem)
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withNews newsEntity: NewsItemEntity) {
        if let cell = cell as? NewsTableViewCell {
            
            
            cell.categoryLabel.text = "Category"
            cell.titleLabel.text = "Content"

            if let urlString = newsEntity.coverPhotoUrl {
                let url = URL(string: urlString)!
                cell.thumbnailImageView.hnk_setImageFromURL(url)
            }
            cell.unreadCircleView.isHidden = newsEntity.isRead
            if let date = newsEntity.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd hh:mm"
                cell.dateLabel.text = dateFormatter.string(from: date as Date)
            }
            cell.categoryLabel.text = newsEntity.category
            cell.titleLabel.text = newsEntity.title
            
           // cell.configure(for: news)
        }
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<NewsItemEntity> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<NewsItemEntity> = NewsItemEntity.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }

}
// MARK: - Fetched results controller delegate

extension NewsListViewController : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            return
        }
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell, withNews: anObject as! NewsItemEntity)
            }
        case .move:
            if let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell, withNews: anObject as! NewsItemEntity)
                tableView.moveRow(at: indexPath, to: newIndexPath!)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    //     func controllerDidChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
    //         // In the simplest, most efficient, case, reload the table view.
    //         tableView.reloadData()
    //     }
}

