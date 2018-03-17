//
//  TagsTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/3/5.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import CoreData

class TagsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate {
    var tags:[String] = []
    var fetchResultController: NSFetchedResultsController<TagMO>!
    var tagsData:[TagMO] = []
    
    var choosedTags: [String] = []
    var chooseTagsInit: [String] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
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
        
        for tag in tagsData {
            tags.append(tag.name!)
        }
        tags = tags.sorted()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tags = tags.sorted()
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
        return tags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagsCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = tags[indexPath.row]
        cell.selectionStyle = .none
        if chooseTagsInit.count > 0 {
            for chooseTagsInitString in chooseTagsInit {
                if chooseTagsInitString == tags[indexPath.row] {
                    cell.accessoryType = .checkmark
                    choosedTags.append(chooseTagsInitString)
                }
            }
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.none {
            if self.choosedTags.count >= 3 {
                let alertController = UIAlertController(title: nil, message: NSLocalizedString("Can't set more than 3 tags", comment: "Can't set more than 3 tags"), preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                present(alertController, animated: true, completion: nil)
            } else {
                self.choosedTags.append(tags[indexPath.row])
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        } else {
            self.choosedTags.remove(at: self.choosedTags.index(of: tags[indexPath.row])!)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
    }

}
