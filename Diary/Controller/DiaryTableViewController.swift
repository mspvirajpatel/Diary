//
//  DiaryTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/21.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
import Foundation

class DiaryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {
    
    var authView = UIView()
    var searchController: UISearchController?
    var feedbackGenerator : UISelectionFeedbackGenerator? = nil
    
    var searchResults: [DiaryMO] = []
    var notebook: NotebookMO!
    let initDiaryArray: [InitialDiary] = [
        InitialDiary(title: NSLocalizedString("Welcome to ", comment: "Welcome to ") + Bundle.main.displayName, content: "    " + Bundle.main.displayName + NSLocalizedString(" integrates notes with journals in one application.", comment: " integrates notes with journals in one application."), image: "iniDiary-1.jpg", tag: NSLocalizedString("diary", comment: "diary") + " " + NSLocalizedString("learn", comment: "learn") + " " + NSLocalizedString("notes", comment: "notes"), weather: "sunny"),
        InitialDiary(title: NSLocalizedString("Tags", comment: "Tags"), content: NSLocalizedString("    You can add up to 3 tags for your own notes, to make it easier to search.\r\n    ", comment: "    You can add up to 3 tags for your own notes, to make it easier to search.\r\n    ") + Bundle.main.displayName + NSLocalizedString("It will create some common tags for you. If you need to manage the tags, please add, modify, and delete tags in the upper right corner of Settings->Tag Management.", comment: "It will create some common tags for you. If you need to manage the tags, please add, modify, and delete tags in the upper right corner of Settings->Tag Management."), image: "iniDiary-2.jpg", tag: NSLocalizedString("work", comment: "work") + " " + NSLocalizedString("notes", comment: "notes"), weather: "cloudy"),
        InitialDiary(title: NSLocalizedString("Never lose", comment: "Never lose"), content: "    " + Bundle.main.displayName + NSLocalizedString("Using Apple's CloudKit for synchronization, all your diaries and notes are synchronized between iPad and iPhone.\r\n\r\n    tips: However, after you delete your notes, the cloud will automatically be deleted.", comment: "Using Apple's CloudKit for synchronization, all your diaries and notes are synchronized between iPad and iPhone.\r\n\r\n    tips: However, after you delete your notes, the cloud will automatically be deleted."), image: "iniDiary-3.jpg", tag: NSLocalizedString("learn", comment: "learn"), weather: "rain"),
        InitialDiary(title: NSLocalizedString("Encryption", comment: "Encryption"), content: NSLocalizedString("    You can protect your diary by turning on Face ID or Touch ID in the upper right corner of Settings->System. Every time you completely exit the app, you will be asked to verify your identity", comment: "    You can protect your diary by turning on Face ID or Touch ID in the upper right corner of Settings->System. Every time you completely exit the app, you will be asked to verify your identity"), image: "iniDiary-4.jpg", tag: NSLocalizedString("notes", comment: "notes"), weather: "snow"),
        InitialDiary(title: NSLocalizedString("Recover your notes", comment: "Recover your notes"), content: NSLocalizedString("    If you delete", comment: "    If you delete") + Bundle.main.displayName + NSLocalizedString(",Your notes will remain on the iCloud, And only you can see it.\r\n    If you download it again", comment: ",Your notes will remain on the iCloud, And only you can see it.\r\n    If you download it again") + Bundle.main.displayName + NSLocalizedString(",You can view the notes from every devices from the upper-right corner of Settings->iCloud. Click the sync button in the upper right corner to automatically restore your notes from iCloud.", comment: ",You can view the notes from every devices from the upper-right corner of Settings->iCloud. Click the sync button in the upper right corner to automatically restore your notes from iCloud."), image: "iniDiary-5.jpg", tag: NSLocalizedString("work", comment: "work"),  weather: "overcast"),
        InitialDiary(title: NSLocalizedString("Notes without picture", comment: "Notes without picture"), content: NSLocalizedString("If your notes do not include pictures, then", comment: "If your notes do not include pictures, then") + Bundle.main.displayName + NSLocalizedString("The content of the note will displayed directly. After you add a picture, the picture will be displayed.", comment: "The content of the note will displayed directly. After you add a picture, the picture will be displayed."), image: "", tag: NSLocalizedString("notes", comment: "notes"),  weather: "tornado")
    ]
    
    let monthArray = ["Jan.", "Feb.", "Mar.", "Apr.", "May.", "June.", "July.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."]
    let weekArray = ["Sun.", "Mon.", "Tues.", "Wed.", "Thur.", "Fri.", "Sat."]
    let colorWeek: [UIColor] = [
        UIColor(red: 65.0/255.0, green: 131.0/255.0, blue: 215.0/255.0, alpha: 1.0),
        UIColor(red: 217.0/255.0, green: 30.0/255.0, blue: 24.0/255.0, alpha: 1.0),
        UIColor(red: 232.0/255.0, green: 126.0/255.0, blue: 4.0/255.0, alpha: 1.0),
        UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0),
        UIColor(red: 219.0/255.0, green: 10.0/255.0, blue: 91.0/255.0, alpha: 1.0),
        UIColor(red: 102.0/255.0, green: 51.0/255.0, blue: 153.0/255.0, alpha: 1.0),
        UIColor(red: 38.0/255.0, green: 166.0/255.0, blue: 91.0/255.0, alpha: 1.0)
    ]
    
    var slideOutTransition = SlideOutTransitionAnimator()
    var activityController: UIActivityViewController? = nil
    
    @IBOutlet var emptyDiaryView: UIView!
    @IBOutlet var emptyTitle: UILabel!
    @IBOutlet var navTitle: UINavigationItem!
    @IBOutlet weak var addDiaryBarButtomItem: UIBarButtonItem! {
        didSet {
            addDiaryBarButtomItem.title = ""
            addDiaryBarButtomItem.isEnabled = false
        }
    }
    
    var btn = UIButton(type: .custom)
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        
        dismiss(animated: true, completion: nil)
    }
    
    var fetchResultController: NSFetchedResultsController<DiaryMO>!
    var fetchNoteResultController: NSFetchedResultsController<NotebookMO>!
    var diaries:[DiaryMO] = []
    var notebooks:[NotebookMO] = []
    
    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    @objc func addDiaryButtonTapped(_ sender: UIButton) {
        // Instantiate a new generator.
        feedbackGenerator = UISelectionFeedbackGenerator()
        
        // Prepare the generator when the gesture begins.
        feedbackGenerator?.prepare()
        
        // Trigger selection feedback.
        feedbackGenerator?.selectionChanged()
        
        // Keep the generator in a prepared state.
        feedbackGenerator?.prepare()
        
        feedbackGenerator = nil
        if let newDiaryNavigationController = storyboard?.instantiateViewController(withIdentifier: "NewDiaryNavigationController") as? UINavigationController {
            present(newDiaryNavigationController, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        
        print("screenHeight:\(screenHeight), screenWidth:\(screenWidth)")
        
        tableView.backgroundColor = UIColor.clear
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)]
        
        // SearchBar
        searchController = UISearchController(searchResultsController: nil)
//        self.navigationItem.searchController = searchController
        tableView.tableHeaderView = searchController?.searchBar
        searchController?.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false
        
        searchController?.searchBar.placeholder = NSLocalizedString("Search from tags, title, content...", comment: "Search from tags, title, content...")
        
        searchController?.searchBar.barTintColor = .white
        searchController?.searchBar.backgroundImage = UIImage()
        searchController?.searchBar.alpha = 0.6
        searchController?.searchBar.tintColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        
        // add button
        btn.frame = CGRect(x: screenWidth - 85, y: screenHeight - 85, width: 60, height: 60)
        btn.setImage(UIImage(named: "add-diary"), for: .normal)
        btn.setImage(UIImage(named: "add-diary-choose"), for: [.selected, .highlighted])
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(addDiaryButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(btn)
        
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            btn.trailingAnchor.constraint(equalTo: self.navigationController!.view.trailingAnchor, constant: 10),
//            btn.bottomAnchor.constraint(equalTo: self.navigationController!.view.bottomAnchor, constant: 53),
//            btn.widthAnchor.constraint(equalToConstant: 60),
//            btn.heightAnchor.constraint(equalToConstant: 60)
//        ])
        
        // Prepare the empty view
        tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
//        tableView.backgroundView = emptyDiaryView
//        tableView.backgroundView?.isHidden = true
        tableView.tableFooterView = UIView()
        // Pull to refresh control
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        if UserDefaults.standard.bool(forKey: "isOpenFaceID"){
            if UserDefaults.standard.bool(forKey: "isShouldAuth") {
                performSegue(withIdentifier: "showAuth", sender: self)
            }
        }
        
        navigationController?.hidesBarsOnSwipe = false
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            if UserDefaults.standard.bool(forKey: "isCreateDairyFromCloud") {
                addEmptyDiaryAndDelete()
            }
            
            // Fetch data from data store - Notebook
            let fetchNoteRequest: NSFetchRequest<NotebookMO> = NotebookMO.fetchRequest()
            let sortNoteDescriptor = NSSortDescriptor(key: "update", ascending: false)
            fetchNoteRequest.sortDescriptors = [sortNoteDescriptor]
            
            fetchNoteRequest.predicate = NSPredicate(format: "id == %d", UserDefaults.standard.integer(forKey: "defaultNoteBookId"))
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                fetchNoteResultController = NSFetchedResultsController(fetchRequest: fetchNoteRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                fetchNoteResultController.delegate = self
                
                do {
                    try fetchNoteResultController.performFetch()
                    if let fetchedObjects = fetchNoteResultController.fetchedObjects {
                        notebooks = fetchedObjects
                    }
                } catch {
                    print(error)
                }
            }
            
            if let navTitleString = notebooks[0].name {
                navTitle.title = navTitleString
            }
            
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
            self.tableView.reloadData()
        } else {
            // user first into the App, init the notebook with the "Diary" book
            UserDefaults.standard.set(1, forKey: "defaultNoteBookId")
            UserDefaults.standard.set(1, forKey: "maxNoteBookId")
            UserDefaults.standard.set(0, forKey: "maxDiaryId")
            UserDefaults.standard.set(Date.init(), forKey: "iCloudSync")
            UserDefaults.standard.set(false, forKey: "isOpenNotify")
            UserDefaults.standard.set(false, forKey: "isOpenFaceID")
            UserDefaults.standard.set(false, forKey: "isNewPhoto")
            UserDefaults.standard.set(true, forKey: "isOpenTableView3D")
            UserDefaults.standard.set(true, forKey: "isOpenRotation")
            UserDefaults.standard.set(90, forKey: "tableView3DAngle")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat =  "HH:mm"
            dateFormatter.timeZone = TimeZone.current
            if let date = dateFormatter.date(from: "19:30") {
                print("date1:\(date)")
                UserDefaults.standard.set(date, forKey: "notifyEverydayTime")
            }
            let initTags:[String] = [
                NSLocalizedString("diary", comment: "diary"),
                NSLocalizedString("work", comment: "work"),
                NSLocalizedString("learn", comment: "learn"),
                NSLocalizedString("travel", comment: "travel"),
                NSLocalizedString("life", comment: "life"),
                NSLocalizedString("notes", comment: "notes"),
                NSLocalizedString("food", comment: "food")
            ]
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                notebook = NotebookMO(context: appDelegate.persistentContainer.viewContext)
                notebook.id = "1"
                notebook.name = NSLocalizedString("Diary", comment: "Diary")
                notebook.comment = NSLocalizedString("my diary", comment: "my diary")
                let currentDate = Date.init()
                notebook.create = currentDate
                notebook.update = currentDate
                if let notebookCoverImage = UIImage(named: "weather-background") {
                    let imageName = String(Int(round(Date.init().timeIntervalSince1970))) + randomString(length: 6) + "-image.jpg"
                    let imageStore = ImageStore(name: imageName)
                    if imageStore.storeImage(image: notebookCoverImage) {
                        notebook.coverimage = imageName
                    }
                }
                
                for index in 0..<initTags.count {
                    let tagMO = TagMO(context: appDelegate.persistentContainer.viewContext)
                    tagMO.name = initTags[index]
                }
                
                var iniDiaryDate: Double = 1
                for iniDiary in initDiaryArray {
                    let diary = DiaryMO(context: appDelegate.persistentContainer.viewContext)
                    let currentMaxId = UserDefaults.standard.integer(forKey: "maxDiaryId")
                    UserDefaults.standard.set(currentMaxId + 1, forKey: "maxDiaryId")
                    diary.id = String(Int(currentDate.timeIntervalSince1970.rounded())) + randomString(length: 6) + String(currentMaxId + 1)
                    diary.notebookid = "1"
                    diary.title = iniDiary.title
                    diary.content = iniDiary.content
                    if let diaryImage = UIImage(named: iniDiary.image) {
                        let imageName = String(Int(round(Date.init().timeIntervalSince1970))) + randomString(length: 6) + "-image.jpg"
                        let imageStore = ImageStore(name: imageName)
                        if imageStore.storeImage(image: diaryImage) {
                            diary.image = imageName
                        }
                    }
                    diary.tag = iniDiary.tag
                    diary.weather = iniDiary.weather
                    diary.create = Date.init(timeIntervalSince1970: currentDate.timeIntervalSince1970 - (3600 * 24 * iniDiaryDate))
                    diary.update = Date.init(timeIntervalSince1970: currentDate.timeIntervalSince1970 - (3600 * 24 * iniDiaryDate))
                    iniDiaryDate = iniDiaryDate + 1.0
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
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        btn.removeFromSuperview()
//    }
    
    func addEmptyDiaryAndDelete() {
        // Save to CoreData
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            let diary = DiaryMO(context: context)
            let currentDate = Date.init()
            diary.id = "123123"
            diary.notebookid = "0"
            diary.id = "1"
            diary.recordName = "1"
            diary.title = "1"
            diary.tag = "1"
            diary.weather = "1"
            diary.location = "1"
            diary.create = currentDate
            diary.update = currentDate
            diary.content = ""
            diary.review = "0"
            diary.image = "1"
            print("Saving data to context")
            appDelegate.saveContext()
            context.delete(diary)
        }
        UserDefaults.standard.set(false, forKey: "isCreateDairyFromCloud")
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for changeType: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type(of: (anObject as! NSObject)) == type(of: DiaryMO()) {
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
                diaries = fetchedObjects as! [DiaryMO]
            }
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scroll.....\(tableView.contentOffset.y)")
        let off = tableView.contentOffset.y
        self.btn.frame = CGRect(x: screenWidth - 85, y: off + screenHeight - 85, width: 60, height: 60)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if diaries.count > 0 {
//            tableView.backgroundView?.isHidden = true
//            tableView.separatorStyle = .singleLine
            searchController?.searchBar.isHidden = false
        } else {
//            tableView.backgroundView?.isHidden = false
            emptyTitle.text = NSLocalizedString("I don't have diaries.", comment: "I don't have diaries.")
//            tableView.separatorStyle = .none
            searchController?.searchBar.isHidden = true
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
        cell.contentView.backgroundColor = UIColor.clear
        let diary = (searchController?.isActive)! ? searchResults[indexPath.row] : diaries[indexPath.row]
        
        // Configure the cell...
        
        cell.titleLabel.text = diary.title
        if let imageName = diary.image, let diaryImage = ImageStore(name: imageName).loadImage() {
            cell.thumbnailImageView.image = diaryImage
            cell.contentLabel.isHidden = true
            if cell.contentLargeUILabel.frame.width > 100 {
                cell.contentLargeUILabel.isHidden = false
                cell.contentLargeUILabel.text = diary.content!
            } else {
                cell.contentLargeUILabel.isHidden = true
            }
        } else {
            cell.thumbnailImageView.image = UIImage()
            if cell.contentLargeUILabel.frame.width > 100 {
                cell.contentLabel.isHidden = true
                cell.contentLargeUILabel.isHidden = false
                cell.contentLargeUILabel.text = diary.content!
            } else {
                cell.contentLargeUILabel.isHidden = true
                cell.contentLabel.isHidden = false
                cell.contentLabel.backgroundColor = .white
                cell.contentLabel.alpha = 0.6
                cell.contentLabel.text = diary.content!
            }
        }
        cell.weatherImageView.image = UIImage(named: diary.weather!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        cell.weekLabel.text = weekArray[Calendar.current.component(.weekday, from: diary.create!) - 1]
        
        cell.monthLabel.textColor = colorWeek[Calendar.current.component(.weekday, from: diary.create!) - 1]
        cell.dayLabel.textColor = colorWeek[Calendar.current.component(.weekday, from: diary.create!) - 1]
        cell.weekLabel.textColor = colorWeek[Calendar.current.component(.weekday, from: diary.create!) - 1]
        
        cell.monthLabel.text = monthArray[Calendar.current.component(.month, from: diary.create!) - 1]
        dateFormatter.dateFormat = "d"
        cell.dayLabel.text = dateFormatter.string(from: diary.create!)
        cell.dateLabel.text = getFriendlyTime(date: diary.update!)
        cell.tagLabel.text = diary.tag
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete the row from the data source
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "Delete"), handler: { (action, sourceView, completionHandler) in
            // Fetch and delete the record from the iCloud
            let diary = self.diaries[indexPath.row]
            let privateDatabase = CKContainer.default().privateCloudDatabase
            print("recordName: \(diary.recordName!)")
            if let recordName = diary.recordName {
                let recordID = CKRecordID(recordName: recordName)
                privateDatabase.fetch(withRecordID: recordID, completionHandler: { (record, error) in
                    if let error = error {
                        // Error handling for failed fetch from public database
                        print("DetailView updateRecordToCloud():\(error.localizedDescription)")
                    }
                    if let record = record {
                        privateDatabase.delete(withRecordID: record.recordID, completionHandler: { (recordID, error) in
                            // Error handling for failed delete to private database
                            if let error = error {
                                print(error.localizedDescription)
                            }
                            print("delete from icloud success")
                        })
                    }
                })
                
            }
            
            // delete in fileManager
            if let diaryName = diary.image {
                if ImageStore(name: diaryName).deleteImage() {
                    print("删除照片文件成功")
                } else {
                    print("删除照片文件失败")
                }
            }
            
            // delete in database
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let diaryToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(diaryToDelete)
                print("delete from coredata success")
                appDelegate.saveContext()
            }
            
            completionHandler(true)
        })
        
        let shareAction = UIContextualAction(style: .normal, title: NSLocalizedString("Share", comment: "Share"), handler: { (action, sourceView, completionHandler) in
            let defaultTitle = self.diaries[indexPath.row].title!
            let defaultContent = self.diaries[indexPath.row].content!
            if let imageName = self.diaries[indexPath.row].image, let imageToShare = ImageStore(name: imageName).loadImage() {
                self.activityController = UIActivityViewController(activityItems: [defaultTitle, imageToShare, defaultContent], applicationActivities: nil)
            } else {
                self.activityController = UIActivityViewController(activityItems: [defaultTitle, defaultContent], applicationActivities: nil)
            }
            
            if let popoverController = self.activityController?.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            
            self.present(self.activityController!, animated: true, completion: nil)

            self.activityController?.completionWithItemsHandler = {
                (activity, success, items, error) in
                if success {
                    switch activity!.rawValue {
                    case "com.apple.UIKit.activity.SaveToCameraRoll":
                        let alertController = UIAlertController(title: NSLocalizedString("Successfully saved to Photos!", comment: "Successfully saved to Photos!"),
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
                        let alertController = UIAlertController(title: NSLocalizedString("Successfully copied to clipboard!", comment: "Successfully copied to clipboard!"),
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
        
        deleteAction.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 0.6)
        deleteAction.image = UIImage(named: "delete")
        
        shareAction.backgroundColor = UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 38.0/255.0, alpha: 0.6)
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        if UserDefaults.standard.bool(forKey: "isOpenTableView3D") {
            if UserDefaults.standard.bool(forKey: "isOpenRotation") {
                let rotationAngleInRadians = CGFloat(UserDefaults.standard.integer(forKey: "tableView3DAngle")) * CGFloat(Double.pi/180.0)
                cell.layer.transform = CATransform3DMakeRotation(rotationAngleInRadians, 0, 0, 1)
            } else {
                cell.layer.transform = CATransform3DTranslate(CATransform3DIdentity, -500, 100, 0)
            }
            UIView.animate(withDuration: 1.0, animations: {
                cell.layer.transform = CATransform3DIdentity
            })
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! DetailViewController
                //print(diaries[indexPath.row].description)
                destinationController.diary = (searchController?.isActive)! ? searchResults[indexPath.row] : diaries[indexPath.row]
//                destinationController.navigationController?.navigationItem = navTitle
                destinationController.hidesBottomBarWhenPushed = true
            }
        }
        
        if segue.identifier == "showNotebook" {
            let toViewController = segue.destination
            toViewController.transitioningDelegate = slideOutTransition
        }
    }
    
    // MARK: - SearchController
    func filterContent(for searchText: String) {
        searchResults = diaries.filter({ (diary) -> Bool in
            if let title = diary.title, let tag = diary.tag, let content = diary.content {
                let isMatch = title.localizedCaseInsensitiveContains(searchText) || tag.localizedCaseInsensitiveContains(searchText) || content.localizedCaseInsensitiveContains(searchText)
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
    
    // MARK: - 3D Touch
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }
        
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            return nil
        }
        
        let selectedDiary = diaries[indexPath.row]
        detailViewController.diary = selectedDiary
        detailViewController.preferredContentSize = CGSize(width: 0.0, height: screenHeight - 200)
        previewingContext.sourceRect = cell.frame
        return detailViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
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
    
    
    func transformToPinyin(str: String, hasBlank: Bool = false) -> String {
        let stringRef = NSMutableString(string: str) as CFMutableString
        CFStringTransform(stringRef,nil, kCFStringTransformToLatin, false) // 转换为带音标的拼音
        CFStringTransform(stringRef, nil, kCFStringTransformStripCombiningMarks, false) // 去掉音标
        let pinyin = stringRef as String
        return hasBlank ? pinyin : pinyin.replacingOccurrences(of: " ", with: "")
    }
    
    //判断字符串中是否有中文
    func isIncludeChinese(str: String) -> Bool {
        for ch in str.unicodeScalars {
            if (0x4e00 < ch.value  && ch.value < 0x9fff) { return true } // 中文字符范围：0x4e00 ~ 0x9fff
        }
        return false
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func getFriendlyTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        var dateFormatString = ""
        
        let timeInterval = Int(round(date.timeIntervalSince1970))
        let currentInterval = Int(round(Date.init().timeIntervalSince1970))
        let diff = currentInterval - timeInterval
        if diff / (3600 * 24 * 365) >= 1 {
            dateFormatString = NSLocalizedString("yyyy", comment: "yyyy")
        } else {
            if diff / (3600 * 24) >= 7 {
                dateFormatString = "HH:mm"
            } else {
                if diff / 3600 >= 24 {
                    dateFormatString = "HH:mm"
                } else {
                    if diff / 3600 >= 1 {
                        return String(diff / (3600)) + NSLocalizedString("hours ago", comment: "hours ago")
                    } else {
                        if diff / 60 >= 1 {
                            return String(diff / (60)) + NSLocalizedString("minutes ago", comment: "minutes ago")
                        } else {
                            return NSLocalizedString("recently", comment: "recently")
                        }
                        
                    }
                }
            }
        }
        dateFormatter.dateFormat = dateFormatString
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func getFriendlyDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        var dateFormatString = ""
        
        let timeInterval = Int(round(date.timeIntervalSince1970))
        let currentInterval = Int(round(Date.init().timeIntervalSince1970))
        let diff = currentInterval - timeInterval
        if diff / (3600 * 24 * 365) >= 1 {
            dateFormatString = NSLocalizedString("yyyy-MM-dd", comment: "yyyy-MM-dd")
        } else {
            if diff / (3600 * 24) >= 7 {
                dateFormatString = NSLocalizedString("MM-dd", comment: "MM-dd")
            } else {
                if diff / 3600 >= 24 {
                    return String(diff / (3600 * 24)) + NSLocalizedString("days ago", comment: "days ago")
                } else {
                    if diff / 3600 >= 1 {
                        return String(diff / (3600)) + NSLocalizedString("hours ago", comment: "hours ago")
                    } else {
                        if diff / 60 >= 1 {
                            return String(diff / (60)) + NSLocalizedString("minutes ago", comment: "minutes ago")
                        } else {
                            return NSLocalizedString("recently", comment: "recently")
                        }
                        
                    }
                }
            }
        }
        dateFormatter.dateFormat = dateFormatString
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
}

extension Bundle {
    var displayName: String {
        let name = object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        return name ?? object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    }
}
