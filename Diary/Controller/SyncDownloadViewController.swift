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
import MapKit

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
    var diary: DiaryMO!
    var progressIndex: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchDataFromCoredata()
        let alertController = UIAlertController(title: nil, message: "下载过程中遇到同一笔记会替换为最新", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (alertAction) in
            
            self.fetchDataFromCloud()
        }))
        present(alertController, animated: true, completion: nil)
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
                    self.diaries = fetchedObjects
                    print("Completed the download of Core data")
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
                self.iCloudDiaries = results
                print("Completed the download of iCloud data")
                self.compareCoredataFromCloud()
            }
        }
    }
    
    func compareCoredataFromCloud() {
        print("--- 开始查找 ---")
        for cloudDiary in iCloudDiaries {
            self.downloadProgress.progress = self.progressIndex / Float(iCloudDiaries.count)
            self.progressIndex = self.progressIndex + 1
            print("iCloud id:\(cloudDiary.object(forKey: "id") as! String) 开始查找 ---")
            var isInCoredata = false
            for coredataDiary in diaries {
                print("iCloud id:\(cloudDiary.object(forKey: "id") as! String) 开始查找 --- coredata id:\(coredataDiary.id!)")
                if coredataDiary.id! == cloudDiary.object(forKey: "id") as? String {
                    print("iCloud id:\(cloudDiary.object(forKey: "id") as! String) 找到与coredata中相同的 ---")
                    isInCoredata = true
                    let cloudUpdate = cloudDiary.object(forKey: "modifiedAt") as? Date
                    if cloudUpdate! > coredataDiary.update! {
                        print("iCloud id:\(cloudDiary.object(forKey: "id") as! String) 上的内容较新，执行更新 ---")
                        //执行更新 下载 cloudDiaries.recordID
                        // update data from data store - Diary
                        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                            let context = appDelegate.persistentContainer.viewContext
                            let fetchRequest: NSFetchRequest<DiaryMO> = DiaryMO.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "id == %@", coredataDiary.id!)
                            do {
                                let results = try context.fetch(fetchRequest)
                                fetchRequest.returnsObjectsAsFaults = false
                                if(results.count > 0 ){
                                    results[0].setValue(cloudDiary.object(forKey: "title") as? String, forKey: "title")
                                    results[0].setValue(cloudDiary.object(forKey: "content") as? String, forKey: "content")
                                    results[0].setValue(cloudDiary.object(forKey: "tag") as? String, forKey: "tag")
                                    results[0].setValue(cloudDiary.object(forKey: "modifiedAt") as! Date, forKey: "update")
                                    try context.save();
                                    print("更新成功.....")
                                } else {
                                    print("No results to save")
                                }
                            } catch{
                                print("There was an error")
                            }
                        }
                    }
                }
            }
            if !isInCoredata {
                // 执行新建
                // Save to CoreData
                print("iCloud id:\(cloudDiary.object(forKey: "id") as! String) 没有在coredata中找到，执行新建 ---")
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    let context = appDelegate.persistentContainer.viewContext
                    diary = DiaryMO(context: context)
                    
                    diary.id = cloudDiary.object(forKey: "id") as? String
                    diary.recordName = cloudDiary.recordID.recordName
                    diary.title = cloudDiary.object(forKey: "title") as? String
                    diary.tag = cloudDiary.object(forKey: "tag") as? String
                    diary.weather = cloudDiary.object(forKey: "weather") as? String
                    let location = cloudDiary.object(forKey: "location") as! CLLocation
                    let geoCoder = CLGeocoder()
                    geoCoder.reverseGeocodeLocation(location, preferredLocale: Locale.current, completionHandler: { (placemarks, error) in
                        if let error = error {
                            print(error)
                            return
                        }
                        
                        if let placemarks = placemarks {
                            let placemarkPostalAddress = placemarks[0].postalAddress!
                            let postalAddress = placemarkPostalAddress.city + placemarkPostalAddress.subLocality + placemarkPostalAddress.street
                            
                            let userLocation = UserLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, postalAddress: postalAddress)
                            let jsonEncoder = JSONEncoder()
                            do {
                                let jsonData = try jsonEncoder.encode(userLocation)
                                self.diary.location = String(data: jsonData, encoding: .utf8)!
                            }
                            catch {
                                print(error)
                            }
                        }
                    })
                    
                    diary.create = cloudDiary.object(forKey: "createdAt") as? Date
                    diary.update = cloudDiary.object(forKey: "modifiedAt") as? Date
                    diary.content = cloudDiary.object(forKey: "content") as? String
                    diary.review = cloudDiary.object(forKey: "review") as? String
                    diary.notebookid = "1"
                    if let image = cloudDiary.object(forKey: "image"), let imageAsset = image as? CKAsset {
                        if let imageData = try? Data.init(contentsOf: imageAsset.fileURL) {
                            diary.image = imageData
                        }
                    }
                    
                    print("新建成功")
                    appDelegate.saveContext()
                }
            }
        }
    }

}
