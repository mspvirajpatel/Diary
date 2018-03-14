//
//  DiscoverTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/28.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import CloudKit
import MapKit

class DiscoverTableViewController: UITableViewController {
    
    var diaries: [CKRecord] = []
    var spinner = UIActivityIndicatorView()
    private var imageCache = NSCache<CKRecordID, NSURL>()
    
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
        
        // Pull to refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure navigation bar appearance
        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)]
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func fetchRecordsFromCloud() {
        // Remove existing records before refreshing
        diaries.removeAll()
        tableView.reloadData()
        
        // Fetch Data using Convenience API
        let cloudContainer = CKContainer.default()
        let privateDatabase = cloudContainer.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Diary", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "modifiedAt", ascending: false)]
        // Create the query with the query
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["title", "tag", "content", "modifiedAt", "deviceName"]
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
                if let refreshControl = self.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
            }
        }
        // Execute the query
        privateDatabase.add(queryOperation)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCell", for: indexPath) as! DiscoverTableViewCell
        
        // Configure the Cell...
        let diary = diaries[indexPath.row]
        
        cell.titleLabel.text = diary.object(forKey: "title") as? String
        cell.fullImageView.image = UIImage(named: "photo")
        let updateDate = diary.object(forKey: "modifiedAt") as? Date
        cell.updateDateLabel.text = self.getFriendlyDate(date: updateDate!) + " 已同步"
        cell.tagLabel.text = diary.object(forKey: "tag") as? String
        let deviceName = diary.object(forKey: "content") as? String
        if let deviceName = deviceName {
            cell.contentTextView.text = deviceName
        } else {
            cell.contentTextView.text = "未知设备"
        }
        cell.deviceNameLabel.text = diary.object(forKey: "deviceName") as? String
        // Check if the image is stored in cache
        if let imageFileURL = imageCache.object(forKey: diary.recordID) {
            // Fetch image from cache
            print("Get image from cache")
            if let imageData = try? Data.init(contentsOf: imageFileURL as URL) {
                cell.fullImageView.image = UIImage(data: imageData)
            }
        } else {
            let publicDatabase = CKContainer.default().privateCloudDatabase
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
                            cell.fullImageView.image = UIImage(data: imageData)
                            cell.setNeedsLayout()
                        }
                        // Add the image URL to cache
                        self.imageCache.setObject(imageAsset.fileURL as NSURL, forKey: diary.recordID)
                    }
                }
            }
            publicDatabase.add(fetchRecordsImageOperation)
        }
        return cell
    }

}
