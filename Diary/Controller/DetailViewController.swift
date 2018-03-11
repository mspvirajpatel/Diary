//
//  DetailViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/22.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class DetailViewController: UIViewController, NSFetchedResultsControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    var diary: DiaryMO!
    var fetchDiary: DiaryMO!
    var fetchResultController: NSFetchedResultsController<DiaryMO>!
    var choosedTags = ""
    var recordName = ""
    
    var defaults = UserDefaults(suiteName: "group.com.niuran.diary")!
    
    override var previewActionItems: [UIPreviewActionItem] {
//        let notificationAction = UIPreviewAction.init(title: "Share", style: .default) { (action, viewController) in

        let cancelAction = UIPreviewAction.init(title: "Cancel", style: .destructive) { (action, viewController) in
            
        }
        
        return [cancelAction]
    }
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var fullImageView: UIImageView!

    @IBOutlet weak var tagButton: UIButton! {
        didSet {
            tagButton.layer.cornerRadius = 5.0
            tagButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = 30.0
            avatarImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var weatherLabel: UILabel!
    @IBOutlet var locationIconImageView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var creatDateLabel: UILabel!
    @IBOutlet var updateDateLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var inputKeyboardView: UIView!
    @IBOutlet weak var inputKeyboardImageView: UIImageView!
    
    @IBAction func tagButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func closeUpdateTags(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func chooseUpdateTag(segue: UIStoryboardSegue) {
        var tagString = ""
        if let source = segue.source as? UpdateTagsTableViewController {
            if source.choosedTags.count > 0 {
                for tag in source.choosedTags {
                    tagString = tagString + tag + " "
                }
                tagString.remove(at: tagString.index(before: tagString.endIndex))
                tagButton.setTitle(tagString, for: UIControlState.normal)
            } else {
                tagButton.setTitle("tag", for: UIControlState.normal)
            }
            
            print("tagStartString:\(tagStartString)")
            print("tagchange:\(tagString)")
            
            // Save Tag
            if tagStartString != tagString {
                let currentDate = Date.init()
                // update data from data store - Diary
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    let context = appDelegate.persistentContainer.viewContext
                    let fetchRequest: NSFetchRequest<DiaryMO> = DiaryMO.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", diary.id!)
                    
                    do {
                        let results = try context.fetch(fetchRequest)
                        fetchRequest.returnsObjectsAsFaults = false
                        
                        if(results.count > 0 ){
                            results[0].setValue(tagString, forKey: "tag")
                            results[0].setValue(currentDate, forKey: "update")
                            try context.save();
                            print("Saved.....")
                        } else {
                            print("No results to save")
                        }
                    } catch{
                        print("There was an error")
                    }
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
                dateFormatter.timeZone = TimeZone.current
                self.updateDateLabel.text = "修改于" + dateFormatter.string(from: currentDate)
            }
        }
    }
    
    var doneButton = UIButton()
    var textViewStartString = ""
    var textViewEndString = ""
    var textFieldStartString = ""
    var textFieldEndString = ""
    var tagStartString = ""
    
    @objc func buttonClick(_ sender: UIButton) {
        view.endEditing(true)
        
        if textFieldStartString != textFieldEndString || textViewStartString != textViewEndString {
            let currentDate = Date.init()
            
            // Fetch and save the record from the database
            let privateDatabase = CKContainer.default().privateCloudDatabase
            print("recordName: \(diary.recordName!)")
            if let recordName = diary.recordName {
                let recordID = CKRecordID(recordName: recordName)
                privateDatabase.fetch(withRecordID: recordID, completionHandler: { (record, error) in
                    if let error = error {
                        // Error handling for failed fetch from public database
                        print("DetailView updateRecordToCloud():\(error.localizedDescription)")
                    } else {
                        // Modify the record and save it to the database
                        if let record = record {
                            if self.textFieldStartString != self.textFieldEndString {
                                record.setValue(self.textFieldEndString, forKey: "title")
                            }
                            if self.textViewStartString != self.textViewEndString {
                                record.setValue(self.textViewEndString, forKey: "content")
                            }
                            record.setValue(Date.init(), forKey: "modifiedAt")
                            privateDatabase.save(record, completionHandler: { (savedRecord, saveError) in
                                // Error handling for failed save to public database
                            })
                        }
                    }
                })
            }
            
            // update data from data store - Diary
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest: NSFetchRequest<DiaryMO> = DiaryMO.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", diary.id!)
                
                do {
                    let results = try context.fetch(fetchRequest)
                    fetchRequest.returnsObjectsAsFaults = false
                    
                    if(results.count > 0 ){
                        if textFieldStartString != textFieldEndString {
                            results[0].setValue(titleTextField.text, forKey: "title")
                        }
                        if textViewStartString != textViewEndString {
                            results[0].setValue(contentTextView.text, forKey: "content")
                        }
                        if self.recordName != "" {
                            results[0].setValue(self.recordName, forKey: "recordName")
                            results[0].setValue(true, forKey: "isUpToCloud")
                        }
                        results[0].setValue(currentDate, forKey: "update")
                        try context.save();
                        print("Saved.....")
                    } else {
                        print("No results to save")
                    }
                } catch{
                    print("There was an error")
                }
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
            dateFormatter.timeZone = TimeZone.current
            self.updateDateLabel.text = "修改于" + dateFormatter.string(from: currentDate)
            
            defaults.setValue(titleTextField.text, forKey: "title")
            defaults.setValue(contentTextView.text, forKey: "content")
        }
        
        doneButton.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.hidesBarsOnSwipe = false
        
        doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        doneButton.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        doneButton.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        doneButton.layer.cornerRadius = 8.0
        doneButton.isHidden = true
        
        navigationItem.largeTitleDisplayMode = .never
        
        // Json Decode the location information
        let jsonDecoder = JSONDecoder()
        if let location = diary.location {
            if location == "" {
                locationButton.setTitle("无", for: UIControlState.normal)
            } else {
                if let jsonData = location.data(using: .utf8) {
                    do {
                        let userLocation = try jsonDecoder.decode(UserLocation.self, from: jsonData)
                        locationButton.setTitle(userLocation.city + userLocation.subLocality + userLocation.street, for: UIControlState.normal)
                    } catch {
                        print("DetailViewController ViewDidLoad JSONDecoder error:\(error)")
                    }
                }
            }
        } else {
            locationButton.setTitle("无", for: UIControlState.normal)
        }
        
        titleTextField.text = diary.title
        titleTextField.delegate = self
        tagButton.setTitle(diary.tag, for: UIControlState.normal)
        tagStartString = diary.tag!
        fullImageView.image = UIImage(data: diary.image!)
        avatarImageView.image = UIImage(named: "avatar-man-stubble")
        authorLabel.text = diary.author
        weatherImageView.image = UIImage(named: diary.weather!)
        weatherLabel.text = diary.weather
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        
        creatDateLabel.text = "创建于" + dateFormatter.string(from: diary.create!)
        updateDateLabel.text = "修改于" + dateFormatter.string(from: diary.update!)
        
        locationIconImageView.image = UIImage(named: "map")
        scrollView.contentInsetAdjustmentBehavior = .never
        
        contentTextView.text = diary.content
        contentTextView.delegate = self
        contentTextView.sizeToFit()
        contentTextView.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        doneButton.isHidden = false
        textFieldStartString = titleTextField.text ?? ""
//        print(textFieldStartString)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldEndString = titleTextField.text ?? ""
//        print(textFieldEndString)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        doneButton.isHidden = false
        animateViewMoving(up: true, moveValue: 300)
        textViewStartString = contentTextView.text
//        print(textViewStartString)
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        animateViewMoving(up: false, moveValue: 300)
        textViewEndString = contentTextView.text
//        print(textViewEndString)
        textView.resignFirstResponder()
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)//CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let destinationController = segue.destination as! MapViewController
            destinationController.diary = diary
        }
        if segue.identifier == "showUpdateTags" {
            let destination = segue.destination as! UpdateTagsTableViewController
            let tagButtonString = self.tagButton.titleLabel?.text ?? "tag"
            if tagButtonString != "tag" {
                let tagArray = tagButtonString.components(separatedBy: " ")
                destination.chooseTagsInit = tagArray
            }
        }
    }

}
