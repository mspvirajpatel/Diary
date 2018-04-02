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

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var diary: DiaryMO!
    var fetchDiary: DiaryMO!
    var fetchResultController: NSFetchedResultsController<DiaryMO>!
    var choosedTags = ""
    var recordName = ""
    
    var defaults = UserDefaults(suiteName: "group.com.niuran.diary")!
    
    override var previewActionItems: [UIPreviewActionItem] {
        let cancelAction = UIPreviewAction.init(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive) { (action, viewController) in
            
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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var creatDateLabel: UILabel!
    @IBOutlet var updateDateLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var inputKeyboardView: UIView!
    @IBOutlet weak var inputKeyboardImageView: UIImageView!
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let photoSourceRequestController = UIAlertController(title: "", message: NSLocalizedString("Please select the photo source", comment: "Please select the photo source"), preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let photoLibraryAction = UIAlertAction(title: NSLocalizedString("Photos", comment: "Photos"), style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        
        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)
        photoSourceRequestController.addAction(cancelAction)
        
        
        if let popoverController = photoSourceRequestController.popoverPresentationController {
            popoverController.sourceView = fullImageView
            popoverController.sourceRect = fullImageView.bounds
        }
        
        present(photoSourceRequestController, animated: true, completion: nil)
    }
    
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
                tagString = ""
                tagButton.setTitle("tag", for: UIControlState.normal)
            }
            
            // Save Tag
            if tagStartString != tagString {
                let currentDate = Date.init()
                
                // Fetch and save the record from the iCloud
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
                                let currentDate = Date.init()
                                record.setValue(tagString, forKey: "tag")
                                record.setValue(currentDate, forKey: "modifiedAt")
                                UserDefaults.standard.set(currentDate, forKey: "iCloudSync")
                                privateDatabase.save(record, completionHandler: { (savedRecord, saveError) in
                                    // Error handling for failed save to public database
                                    if let saveError = saveError {
                                        print(saveError.localizedDescription)
                                    }
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
                dateFormatter.dateFormat = NSLocalizedString("yyyy-MM-dd HH:mm:ss", comment: "yyyy-MM-dd HH:mm:ss")
                dateFormatter.timeZone = TimeZone.current
                self.updateDateLabel.text = NSLocalizedString("modifiedAt", comment: "modifiedAt") + dateFormatter.string(from: currentDate)
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
        
        if textFieldEndString == "" && textViewEndString == "" {
            let alertController = UIAlertController(title: NSLocalizedString("The title or content should not be empty", comment: "The title or content should not be empty"),
                                                    message: nil, preferredStyle: .alert)
            //显示提示框
            self.present(alertController, animated: true, completion: nil)
            titleTextField.text = textFieldStartString
            textFieldEndString = textFieldStartString
            contentTextView.text = textViewStartString
            textViewEndString = textViewStartString
            //两秒钟后自动消失
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
        } else {
            if textFieldStartString != textFieldEndString || textViewStartString != textViewEndString {
                let currentDate = Date.init()
                
                // Fetch and save the record from the iCloud
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
                                let currentDate = Date.init()
                                record.setValue(currentDate, forKey: "modifiedAt")
                                UserDefaults.standard.set(currentDate, forKey: "iCloudSync")
                                privateDatabase.save(record, completionHandler: { (savedRecord, saveError) in
                                    // Error handling for failed save to public database
                                    if let saveError = saveError {
                                        print(saveError.localizedDescription)
                                    }
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
                dateFormatter.dateFormat = NSLocalizedString("yyyy-MM-dd HH:mm:ss", comment: "yyyy-MM-dd HH:mm:ss")
                dateFormatter.timeZone = TimeZone.current
                self.updateDateLabel.text = NSLocalizedString("modifiedAt", comment: "modifiedAt") + dateFormatter.string(from: currentDate)
                
                defaults.setValue(titleTextField.text, forKey: "title")
                defaults.setValue(contentTextView.text, forKey: "content")
            }
        }
        
        doneButton.isHidden = true
    }
    
    @objc func back(_ sender: UIBarButtonItem) {
        // Perform your custom actions
        print("updateDiary")
        view.endEditing(true)
        if textFieldEndString == "" && textViewEndString == "" {
            let alertController = UIAlertController(title: NSLocalizedString("The title or content should not be empty", comment: "The title or content should not be empty"),
                                                    message: nil, preferredStyle: .alert)
            //显示提示框
            self.present(alertController, animated: true, completion: nil)
            titleTextField.text = textFieldStartString
            textFieldEndString = textFieldStartString
            contentTextView.text = textViewStartString
            textViewEndString = textViewStartString
            //两秒钟后自动消失
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
        } else {
            if textFieldStartString != textFieldEndString || textViewStartString != textViewEndString {
                let currentDate = Date.init()
                
                // Fetch and save the record from the iCloud
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
                                let currentDate = Date.init()
                                record.setValue(currentDate, forKey: "modifiedAt")
                                UserDefaults.standard.set(currentDate, forKey: "iCloudSync")
                                privateDatabase.save(record, completionHandler: { (savedRecord, saveError) in
                                    // Error handling for failed save to public database
                                    if let saveError = saveError {
                                        print(saveError.localizedDescription)
                                    }
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
                dateFormatter.dateFormat = NSLocalizedString("yyyy-MM-dd HH:mm:ss", comment: "yyyy-MM-dd HH:mm:ss")
                dateFormatter.timeZone = TimeZone.current
                self.updateDateLabel.text = NSLocalizedString("modifiedAt", comment: "modifiedAt") + dateFormatter.string(from: currentDate)
                
                defaults.setValue(titleTextField.text, forKey: "title")
                defaults.setValue(contentTextView.text, forKey: "content")
            }
        }
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(named: "arrow-left"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        scrollView.contentInsetAdjustmentBehavior = .never
        
        doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        doneButton.setTitle(NSLocalizedString("Done", comment: "Done"), for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        doneButton.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)
        doneButton.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        doneButton.layer.cornerRadius = 8.0
        doneButton.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        
        navigationItem.largeTitleDisplayMode = .never
        
        locationButton.isHidden = false
        // Json Decode the location information
        let jsonDecoder = JSONDecoder()
        if let location = diary.location {
            if location == "" {
                locationButton.isHidden = true
            } else {
                if let jsonData = location.data(using: .utf8) {
                    do {
                        let userLocation = try jsonDecoder.decode(UserLocation.self, from: jsonData)
                        locationButton.setTitle(userLocation.postalAddress, for: UIControlState.normal)
                    } catch {
                        print("DetailViewController ViewDidLoad JSONDecoder error:\(error)")
                    }
                }
            }
        } else {
            locationButton.isHidden = true
        }
        
        titleTextField.text = diary.title
        titleTextField.delegate = self
        if diary.tag == "" {
            tagButton.setTitle("tag", for: UIControlState.normal)
        } else {
            tagButton.setTitle(diary.tag, for: UIControlState.normal)
        }
        
        tagStartString = diary.tag!
        if let imageName = diary.image, let diaryImage = ImageStore(name: imageName).loadImage() {
                fullImageView.image = diaryImage
        }
        weatherImageView.image = UIImage(named: diary.weather!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = NSLocalizedString("yyyy-MM-dd HH:mm:ss", comment: "yyyy-MM-dd HH:mm:ss")
        dateFormatter.timeZone = TimeZone.current
        
        dateLabel.text = dateFormatter.string(from: diary.create!)
        creatDateLabel.text = NSLocalizedString("createdAt", comment: "createdAt") + dateFormatter.string(from: diary.create!)
        updateDateLabel.text = NSLocalizedString("modifiedAt", comment: "modifiedAt") + dateFormatter.string(from: diary.update!)
        
        contentTextView.text = diary.content
        contentTextView.delegate = self
        contentTextView.sizeToFit()
        contentTextView.isScrollEnabled = false
        if let diaryTitle = diary.title {
            textFieldStartString = diaryTitle
            textFieldEndString = diaryTitle
        }
        
        if let diaryContent = diary.content {
            textViewStartString = diaryContent
            textViewEndString = diaryContent
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        fullImageView.isUserInteractionEnabled = true
        fullImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.hidesBottomBarWhenPushed = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedUIImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            var selectedImage = selectedUIImage
            // This fixes the image orientation <<<---
            if selectedImage.imageOrientation != UIImageOrientation.up {
                UIGraphicsBeginImageContextWithOptions(selectedImage.size, false, selectedImage.scale)
                selectedImage.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: selectedImage.size))
                selectedImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            }
            
            fullImageView.image = selectedImage
            updateImage()
            fullImageView.contentMode = .scaleToFill
            fullImageView.clipsToBounds = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func updateImage() {
        let currentDate = Date.init()
        let imageName = String(Int(round(Date.init().timeIntervalSince1970))) + self.randomString(length: 6) + "-image.jpg"
        let imageStore = ImageStore(name: imageName)
        if let diaryImage = self.fullImageView.image {
            if imageStore.storeImage(image: diaryImage) {
            
                // Fetch and save the record from the iCloud
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
                                let diaryImage = diaryImage
                                // Resize the image
                                let imageData = UIImagePNGRepresentation(diaryImage)!
                                let originalImage = UIImage(data: imageData)!
                                let scalingFator = (originalImage.size.width > 1024) ? 1024 / originalImage.size.width : 1.0
                                let scaledImage = UIImage(data: imageData, scale: scalingFator)!
                                
                                // Write the image to the local file for temporary use
                                let imageFilePath = NSTemporaryDirectory() + imageName
                                let imageFileURL = URL(fileURLWithPath: imageFilePath)
                                try? UIImageJPEGRepresentation(scaledImage, 0.8)?.write(to: imageFileURL)
                                
                                // Create image asset for upload
                                let imageAsset = CKAsset(fileURL: imageFileURL)
                                
                                record.setValue(imageAsset, forKey: "image")
                                record.setValue(currentDate, forKey: "modifiedAt")
                                UserDefaults.standard.set(currentDate, forKey: "iCloudSync")
                                privateDatabase.save(record, completionHandler: { (savedRecord, saveError) in
                                    // Error handling for failed save to public database
                                    if let saveError = saveError {
                                        print(saveError.localizedDescription)
                                    }
                                })
                            }
                        }
                    })
                }
                
                // Delete the image before
                // delete in fileManager
                if let diaryName = diary.image {
                    if ImageStore(name: diaryName).deleteImage() {
                        print("删除照片文件成功")
                    } else {
                        print("删除照片文件失败")
                    }
                } else {
                    print("原来没有照片，无需删除")
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
                            results[0].setValue(imageName, forKey: "image")
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
                dateFormatter.dateFormat = NSLocalizedString("yyyy-MM-dd HH:mm:ss", comment: "yyyy-MM-dd HH:mm:ss")
                dateFormatter.timeZone = TimeZone.current
                self.updateDateLabel.text = NSLocalizedString("modifiedAt", comment: "modifiedAt") + dateFormatter.string(from: currentDate)
            }
        }
    }

}
