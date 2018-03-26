//
//  TagManageTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/3/6.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import CoreData

class TagManageTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate {
    var fetchResultController: NSFetchedResultsController<TagMO>!
    var tagsData:[TagMO] = []
    
    var choosedTags: [String] = []
    var chooseTagsInit: [String] = []
    
    var saveButton = UIButton()
    var newTagTextField = UITextField()
    var historyName = ""
    
    @objc func buttonClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "add a tag", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField { (textField:UITextField!) in
            self.newTagTextField = textField
        }
        alertController.addAction(UIAlertAction(title: "Done", style: .default) { (action:UIAlertAction!) in
            if let newTag = self.newTagTextField.text {
                if self.newTagTextField.text != "" {
                    if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                        let context = appDelegate.persistentContainer.viewContext
                        let fetchRequest: NSFetchRequest<TagMO> = TagMO.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "name == %@", newTag)
                        let results = try? context.fetch(fetchRequest)
                        fetchRequest.returnsObjectsAsFaults = false
                        if results!.count > 0 {
                            let alertWarning = UIAlertController(title: NSLocalizedString("Setting failed", comment: "Setting failed"), message: NSLocalizedString("Duplicate with other tags", comment: "Duplicate with other tags"), preferredStyle: .alert)
                            alertWarning.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: "Done"), style: .cancel, handler: nil))
                            self.present(alertWarning, animated: true, completion: nil)
                        } else {
                            let tagMO = TagMO(context: appDelegate.persistentContainer.viewContext)
                            tagMO.name = newTag
                            print("Saving data to context")
                            appDelegate.saveContext()
                        }
                    }
                }
            }
        })
        present(alertController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true
        tableView.tableFooterView = UIView()
        
        saveButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        saveButton.setImage(UIImage(named: "plus"), for: UIControlState.normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        
        // Fetch tags from CoreData.
        let fetchRequest: NSFetchRequest<TagMO> = TagMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    tagsData = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tagsData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagManageCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = tagsData[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete the row from the data source
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, sourceView, completionHandler) in
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let tagToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(tagToDelete)
                appDelegate.saveContext()
            }
            completionHandler(true)
        })
        
        deleteAction.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        deleteAction.image = UIImage(named: "delete")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeConfiguration
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for changeType: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type(of: (anObject as! NSObject)) == type(of: TagMO()) {
            switch changeType {
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
                tagsData = fetchedObjects as! [TagMO]
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("edit the tag", comment: "edit the tag"), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        alertController.addTextField { (textField:UITextField!) in
            textField.text = self.tagsData[indexPath.row].name!
            self.newTagTextField = textField
            self.historyName = textField.text ?? ""
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: "Done"), style: .default) { (action:UIAlertAction!) in
            if self.historyName == self.newTagTextField.text {
                return
            }
            if let newTag = self.newTagTextField.text {
                if self.newTagTextField.text != "" {
                    if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                        let context = appDelegate.persistentContainer.viewContext
                        let fetchRequest: NSFetchRequest<TagMO> = TagMO.fetchRequest()
                        let fetchReRequest: NSFetchRequest<TagMO> = TagMO.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "name == %@", self.tagsData[indexPath.row].name!)
                        fetchReRequest.predicate = NSPredicate(format: "name == %@", newTag)
                        do {
                            let reResults = try context.fetch(fetchReRequest)
                            fetchReRequest.returnsObjectsAsFaults = false
                            if reResults.count == 0 {
                                let results = try context.fetch(fetchRequest)
                                fetchRequest.returnsObjectsAsFaults = false
                                if results.count > 0 {
                                    results[0].setValue(newTag, forKey: "name")
                                    try context.save();
                                    print("Saved.....")
                                } else {
                                    print("No results to save")
                                }
                            } else {
                                let alertWarning = UIAlertController(title: NSLocalizedString("Setting failed", comment: "Setting failed"), message: "与其他标签重复", preferredStyle: .alert)
                                alertWarning.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: "Done"), style: .cancel, handler: nil))
                                self.present(alertWarning, animated: true, completion: nil)
                            }
                        } catch{
                            print("There was an error")
                        }
                    }
                }
            }
        })
        present(alertController, animated: true, completion: nil)
    }
}
