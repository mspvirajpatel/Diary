//
//  DiaryTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/21.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import CoreData

class DiaryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    var searchController: UISearchController?
    
    var searchResults: [DiaryMO] = []
    var notebook: NotebookMO!
    
    @IBOutlet var emptyDiaryView: UIView!
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    var fetchResultController: NSFetchedResultsController<DiaryMO>!
    var diaries:[DiaryMO] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)]
        
        // SearchBar
        searchController = UISearchController(searchResultsController: nil)
//        self.navigationItem.searchController = searchController
        tableView.tableHeaderView = searchController?.searchBar
        searchController?.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false
        
        searchController?.searchBar.placeholder = "Search diaries..."
        searchController?.searchBar.barTintColor = .white
        searchController?.searchBar.backgroundImage = UIImage()
        searchController?.searchBar.tintColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        
        // Prepare the empty view
        tableView.backgroundView = emptyDiaryView
        tableView.backgroundView?.isHidden = true
        
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<DiaryMO> = DiaryMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
//        let firstName = "Trevor"
//        fetchRequest.predicate = NSPredicate(format: "firstName == %@", firstName)

        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self

            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    diaries = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            return
        } else {
            // user first into the App, init the notebook with the "Diary" book
            UserDefaults.standard.set(1, forKey: "defaultNoteBookId")
            UserDefaults.standard.set(1, forKey: "maxNoteBookId")
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                notebook = NotebookMO(context: appDelegate.persistentContainer.viewContext)
                notebook.id = "1"
                notebook.name = "Diary"
                notebook.author = "匿名"
                notebook.comment = "my diary"
                let currentDate = Date.init()
                notebook.create = currentDate
                notebook.update = currentDate
                if let notebookCoverImage = UIImage(named: "weather-background") {
                    notebook.coverimage = UIImagePNGRepresentation(notebookCoverImage)
                }

                print("Saving data to context")
                appDelegate.saveContext()
            }
            
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
                present(walkthroughViewController, animated: true, completion: nil)
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }

        if let fetchedObjects = controller.fetchedObjects {
            diaries = fetchedObjects as! [DiaryMO]
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if diaries.count > 0 {
            tableView.backgroundView?.isHidden = true
            tableView.separatorStyle = .singleLine
        } else {
            tableView.backgroundView?.isHidden = false
            tableView.separatorStyle = .none
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (searchController?.isActive)! {
            return searchResults.count
        } else {
            return diaries.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DiaryTableViewCell

        let diary = (searchController?.isActive)! ? searchResults[indexPath.row] : diaries[indexPath.row]
        
        // Configure the cell...
        cell.titleLabel.text = diary.title
//        cell.contentLabel.text = diary.content
        cell.thumbnailImageView.image = UIImage(data: diary.image!)
        cell.authorLabel.text = diary.author
        if diary.review == "" {
            cell.reviewLabel.text = "暂无评论"
        } else {
            cell.reviewLabel.text = diary.review! + " 评论"
        }
        cell.tagLabel.text = diary.tag
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete the row from the data source
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, sourceView, completionHandler) in
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let diaryToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(diaryToDelete)
                
                appDelegate.saveContext()
            }
            completionHandler(true)
        })
        
        let shareAction = UIContextualAction(style: .normal, title: "Share", handler: { (action, sourceView, completionHandler) in
            let defaultText = self.diaries[indexPath.row].title!
            let activityController: UIActivityViewController
            if let imageToShare = UIImage(data: self.diaries[indexPath.row].image!) {
                activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
            } else {
                activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            }
            
//            if let popoverController = activityController.popoverPresentationController {
//                if let cell = tableView.cellForRow(at: indexPath) {
//                    popoverController.sourceView = cell
//                    popoverController.sourceRect = cell.bounds
//                }
//            }
            
            self.present(activityController, animated: true, completion: nil)

            activityController.completionWithItemsHandler = {
                (activity, success, items, error) in
                if success {
                    switch activity!._rawValue {
                    case "com.apple.UIKit.activity.SaveToCameraRoll":
                        let alertController = UIAlertController(title: "成功保存到相册!",
                                                                message: nil, preferredStyle: .alert)
                        //显示提示框
                        self.present(alertController, animated: true, completion: nil)
                        //两秒钟后自动消失
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            self.presentedViewController?.dismiss(animated: false, completion: nil)
                        }
//                        print("成功保存到相册！")
                    case "com.apple.UIKit.activity.CopyToPasteboard":
//                        print("成功复制到剪贴板！")
                        let alertController = UIAlertController(title: "成功复制到剪贴板!",
                                                                message: nil, preferredStyle: .alert)
                        //显示提示框
                        self.present(alertController, animated: true, completion: nil)
                        //两秒钟后自动消失
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            self.presentedViewController?.dismiss(animated: false, completion: nil)
                        }
                    default:
                        break
                    }
                }
            }
            completionHandler(true)
            
        })
        
        deleteAction.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        deleteAction.image = UIImage(named: "delete")
        
        shareAction.backgroundColor = UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        shareAction.image = UIImage(named: "share")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        
        return swipeConfiguration
        
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (searchController?.isActive)! {
            return false
        } else {
            return true
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! DetailViewController
                destinationController.diary = (searchController?.isActive)! ? searchResults[indexPath.row] : diaries[indexPath.row]
                destinationController.hidesBottomBarWhenPushed = true
            }
        }
    }
    
    // MARK: - SearchController
    func filterContent(for searchText: String) {
        searchResults = diaries.filter({ (diary) -> Bool in
            if let title = diary.title, let author = diary.author, let tag = diary.tag, let content = diary.content {
                let isMatch = title.localizedCaseInsensitiveContains(searchText) || author.localizedCaseInsensitiveContains(searchText) || tag.localizedCaseInsensitiveContains(searchText) || content.localizedCaseInsensitiveContains(searchText)
                return isMatch
            }
            
            return false
        })
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
