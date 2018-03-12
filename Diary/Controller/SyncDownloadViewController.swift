//
//  SyncDownloadViewController.swift
//  Diary
//
//  Created by 牛苒 on 12/03/2018.
//  Copyright © 2018 牛苒. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

class SyncDownloadViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var downloadProgress: UIProgressView! {
        didSet {
            downloadProgress.progress = 0.0
        }
    }
    var iCloudDiaries: [CKRecord] = []
    var diaries:[DiaryMO] = []
    var fetchResultController: NSFetchedResultsController<DiaryMO>!
    var notSyncID: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.fetchDataFromCoredata()
            
            self.fetchDataFromCloud()
        }

    }
    
    func fetchDataFromCoredata() {
        // Fetch data from data store - Diary
        let fetchRequest: NSFetchRequest<DiaryMO> = DiaryMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "update", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.predicate = NSPredicate(format: "notebookid == %d", UserDefaults.standard.integer(forKey: "defaultNoteBookId"))
        
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
    
    func fetchDataFromCloud() {
        // Fetch Data using Convenience API
        let cloudContainer = CKContainer.default()
        let privateDatabase = cloudContainer.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Diary", predicate: predicate)
        privateDatabase.perform(query, inZoneWith: nil) { (results, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let results = results {
                print("Completed the download of Diary data")
                self.iCloudDiaries = results
            }
        }
    }
    
    func compareCoredataFromCloud() {
        for diary in diaries {
            for cloudDiaries in iCloudDiaries {
                if diary.id! == cloudDiaries.object(forKey: "id") as? String {
                    let cloudUpdate = cloudDiaries.object(forKey: "modifiedAt") as? Date
                    if cloudUpdate! > diary.update! {
                        //执行下载 cloudDiaries.recordID
                    }
                }
            }
        }
    }

}
