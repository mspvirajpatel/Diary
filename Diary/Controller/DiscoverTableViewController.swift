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
    var spinner = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Configure navigation bar appearance
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)]
        
        spinner.activityIndicatorViewStyle = .gray
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150.0), spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        spinner.startAnimating()
        fetchRecordsFromCloud()
    }
    
    func fetchRecordsFromCloud() {
        // Fetch Data using Convenience API
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Diary", predicate: predicate)
        
        // Create the query with the query
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["title", "author", "review"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50
        queryOperation.recordFetchedBlock = { (record) in
            self.diaries.append(record)
        }
        queryOperation.queryCompletionBlock = { (cursor, error) in
            if let error = error {
                print("Failed to get data from iCloud - \(error.localizedDescription)")
                return
            }
            print("Successfully retrieve the data from iCloud")
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.tableView.reloadData()
            }
        }
        // Execute the query
        publicDatabase.add(queryOperation)
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
        
        cell.imageView?.image = UIImage(named: "photo")
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [diary.recordID])
        fetchRecordsImageOperation.desiredKeys = ["image"]
        fetchRecordsImageOperation.queuePriority = .veryHigh
        fetchRecordsImageOperation.perRecordCompletionBlock = { (record, recordID, error) in
            if let error = error {
                print("Failed to get data from iCloud - \(error.localizedDescription)")
                return
            }
            if let diaryRecord = record, let image = diaryRecord.object(forKey: "image"), let imageAsset = image as? CKAsset {
                if let imageData = try? Data.init(contentsOf: imageAsset.fileURL) {
                    DispatchQueue.main.async {
                        cell.imageView?.image = UIImage(data: imageData)
                        cell.setNeedsLayout()
                    }
                }
            }
        }
        publicDatabase.add(fetchRecordsImageOperation)
        return cell
    }

}
