//
//  DiscoverTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/28.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {
    
    var diaries: [CKRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Configure navigation bar appearance
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)]
        fetchRecordsFromCloud()
    }
    
    func fetchRecordsFromCloud() {
        // Fetch Data using Convenience API
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Diary", predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { (results, error) in
            if let error = error {
                print(error)
                return
            }
            if let results = results {
                print("Completed the download of Diary data")
                self.diaries = results
                print(results.description)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
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
        return diaries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCell", for: indexPath)
        
        // Configure the Cell...
        let diary = diaries[indexPath.row]
        cell.textLabel?.text = diary.object(forKey: "title") as? String
        
        if let image = diary.object(forKey: "image"), let imageAsset = image as? CKAsset {
            if let imageData = try? Data.init(contentsOf: imageAsset.fileURL) {
                cell.imageView?.image = UIImage(data: imageData)
            }
        }
        return cell
    }

}
