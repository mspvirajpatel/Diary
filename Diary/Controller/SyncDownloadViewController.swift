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

    @IBOutlet weak var downloadProgress: UIProgressView!
    @IBOutlet var percentLabel: UILabel!
    @IBOutlet weak var outputTextView: UITextView!
    var iCloudDiaries: [CKRecord] = []
    var diaries:[DiaryMO] = []
    var fetchResultController: NSFetchedResultsController<DiaryMO>!
    var notSyncID: [String] = []
    var progressIndex: Float = 1.0
    var createNum = 0
    var updateNum = 0
    var coredataNum = 0
    var cloudNum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outputTextView.text = ""
        downloadProgress.progress = 0.0
        percentLabel.text = "0%"
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("The same note will be replaced with the latest during the download process", comment: "The same note will be replaced with the latest during the download process"), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { (alertAction) in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .destructive, handler: { (alertAction) in
            self.fetchDataFromCoredata()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func fetchDataFromCoredata() {
        // Fetch data from data store - Diary
        outputTextView.text = outputTextView.text + NSLocalizedString("Start loading local data...\r\n", comment: "Start loading local data...\r\n")
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
                    self.outputTextView.text = self.outputTextView.text + NSLocalizedString("Successfully loading local data...\r\n", comment: "Successfully loading local data...\r\n")
                    fetchDataFromCloud()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func fetchDataFromCloud() {
        // Fetch Data using Convenience API
        outputTextView.text = outputTextView.text + NSLocalizedString("Start downloading iCloud data...\r\n", comment: "Start downloading iCloud data...\r\n")
        let cloudContainer = CKContainer.default()
        let privateDatabase = cloudContainer.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Diary", predicate: predicate)
        privateDatabase.perform(query, inZoneWith: nil) { (results, error) in
            if let error = error {
                print(error.localizedDescription)
                self.outputTextView.text = self.outputTextView.text + NSLocalizedString("Error downloading iCloud data, reason:", comment: "Error downloading iCloud data, reason:") + error.localizedDescription + "...\r\n"
            }
            if let results = results {
                self.iCloudDiaries = results
                
                DispatchQueue.main.async {
                    self.outputTextView.text = self.outputTextView.text + NSLocalizedString("Successfully download iCloud data...\r\n", comment: "Successfully download iCloud data...\r\n")
                    self.compareCoredataFromCloud()
                    var resultMessage = ""
                    if self.createNum > 0 {
                        UserDefaults.standard.set(true, forKey: "isCreateDairyFromCloud")
                    }
                    if (self.updateNum + self.createNum) == 0 {
                        resultMessage = NSLocalizedString("After checking, no updates required", comment: "After checking, no updates required")
                    } else {
                        if self.updateNum == 0 {
                            resultMessage = NSLocalizedString("created", comment: "created") + String(self.createNum) + NSLocalizedString(" records to the local, please return to the home page to view", comment: " records to the local, please return to the home page to view")
                        } else {
                            if self.createNum == 0 {
                                resultMessage = NSLocalizedString("updated", comment: "updated") + String(self.updateNum) + NSLocalizedString(" records to the local, please return to the home page to view", comment: " records to the local, please return to the home page to view")
                            } else {
                                resultMessage = NSLocalizedString("created", comment: "created") + String(self.createNum) + NSLocalizedString(" records, and updated ", comment: " records, and updated ") + String(self.updateNum) + NSLocalizedString(" records to the local, please return to the home page to view", comment: " records to the local, please return to the home page to view")
                            }
                        }
                    }
                    let alertController = UIAlertController(title: NSLocalizedString("The result of the execution", comment: "The result of the execution"), message: resultMessage, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: "Done"), style: .default, handler: { (alertAction) in
                        self.navigationController?.popToRootViewController(animated: true)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func compareCoredataFromCloud() {
        self.outputTextView.text = self.outputTextView.text + NSLocalizedString("Starting to compare local data with iCloud data...\r\n", comment: "Starting to compare local data with iCloud data...\r\n")
        self.coredataNum = diaries.count
        self.cloudNum = iCloudDiaries.count
        for cloudDiary in iCloudDiaries {
            //let cloudDiaryId = cloudDiary.object(forKey: "id") as! String
            self.downloadProgress.progress = self.progressIndex / Float(iCloudDiaries.count)
            self.percentLabel.text = String(self.downloadProgress.progress * 100) + "0%"
            self.progressIndex = self.progressIndex + 1
            //self.outputTextView.text = self.outputTextView.text + "开始查找iCloud id:" + cloudDiaryId + "...\r\n"
            var isInCoredata = false
            for coredataDiary in diaries {
                //self.outputTextView.text = self.outputTextView.text + "对比 iCloud id:" + cloudDiaryId + " coredata id:" + coredataDiary.id! + "...\r\n"
                if coredataDiary.id! == cloudDiary.object(forKey: "id") as? String {
                    //self.outputTextView.text = self.outputTextView.text + "找到相同iCloud id:" + cloudDiaryId + " coredata id:" + coredataDiary.id! + "...\r\n"
                    isInCoredata = true
                    let cloudUpdate = cloudDiary.object(forKey: "modifiedAt") as? Date
                    if cloudUpdate! > coredataDiary.update! {
                        //self.outputTextView.text = self.outputTextView.text + "iCloud id: " + cloudDiaryId + "上的内容较新，执行更新...\r\n"
                        self.updateNum = self.updateNum + 1
                        // 执行更新 下载 cloudDiaries.recordID
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
                                    //self.outputTextView.text = self.outputTextView.text + "iCloud id: " + cloudDiaryId + "更新成功...\r\n"
                                } else {
                                    print("No results to save")
                                }
                            } catch{
                                print("There was an error")
                            }
                        }
                    } else {
                        //self.outputTextView.text = self.outputTextView.text + "iCloud id: " + cloudDiaryId + "上的内容与本地文件相同，无需更新...\r\n"
                    }
                    diaries.remove(at: diaries.index(of: coredataDiary)!)
                    break
                }
            }
            if !isInCoredata {
                // 执行新建
                // Save to CoreData
                //self.outputTextView.text = self.outputTextView.text + "iCloud id: " + cloudDiaryId + "没有在coredata中找到，执行新建...\r\n"
                self.createNum = self.createNum + 1
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    let context = appDelegate.persistentContainer.viewContext
                    let diary = DiaryMO(context: context)
                    
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
                                diary.location = String(data: jsonData, encoding: .utf8)!
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
                            let imageName = String(Int(round(Date.init().timeIntervalSince1970))) + randomString(length: 6) + "-image.jpg"
                            let imageStore = ImageStore(name: imageName)
                            if let savedImage = UIImage(data: imageData) {
                                if imageStore.storeImage(image: savedImage) {
                                    diary.image = imageName
                                } else {
                                    diary.image = ""
                                }
                            }
                        }
                    }
                    //self.outputTextView.text = self.outputTextView.text + "iCloud id: " + cloudDiaryId + "新建到本地成功...\r\n"
                    appDelegate.saveContext()
                }
            }
        }
    }
    
}
