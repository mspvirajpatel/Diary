//
//  NewDiaryTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/23.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import CloudKit
import CoreData
import MapKit
import CoreLocation
import Contacts

class NewDiaryTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,CLLocationManagerDelegate {
    
    var diary: DiaryMO!
    var choosedWeatherButtonText = ""
    var choosedTags = ""
    var noteBookName = ""
    var currentDate = Date()
    let locationManager = CLLocationManager()
    var userCurrentLocation = ""
    var recordName = ""
    var userCLLocation = CLLocation()
    var isGetUserLocation = false
    var isSetPhoto = false
    let placeholderString = NSLocalizedString("write some thing today...", comment: "write some thing today...")
    var defaults = UserDefaults(suiteName: "group.com.niuran.diary")!
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if !isSetPhoto && titleTextField.text == "" && (contentTextView.text == "" || contentTextView.text == placeholderString) {
            let alertController = UIAlertController(title: NSLocalizedString("Can't not create an empty note", comment: "Can't not create an empty note"),
                                                    message: nil, preferredStyle: .alert)
            //显示提示框
            self.present(alertController, animated: true, completion: nil)
            //两秒钟后自动消失
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
            }
        } else {
        
            // Prepare data
            let currentMaxId = UserDefaults.standard.integer(forKey: "maxDiaryId")
            UserDefaults.standard.set(currentMaxId + 1, forKey: "maxDiaryId")
            let dataId = String(Int(currentDate.timeIntervalSince1970.rounded())) + randomString(length: 6) + String(currentMaxId + 1)
            
            // Save to iCloud
            let record = CKRecord(recordType: "Diary")
            self.recordName = record.recordID.recordName
            record.setValue(dataId, forKey: "id")
            record.setValue(titleTextField.text, forKey: "title")
            if tagButton.titleLabel?.text == "tag" {
                record.setValue("", forKey: "tag")
            } else {
                record.setValue(tagButton.titleLabel?.text, forKey: "tag")
            }
            record.setValue(UIDevice.current.name, forKey: "deviceName")
            record.setValue(self.choosedWeatherButtonText, forKey: "weather")
            if isGetUserLocation {
                record.setValue(self.userCLLocation, forKey: "location")
            } else {
                record.setValue(CLLocation(latitude: 0.0, longitude: 0.0), forKey: "location")
            }
            
            record.setValue(currentDate, forKey: "createdAt")
            record.setValue(currentDate, forKey: "modifiedAt")
            UserDefaults.standard.set(currentDate, forKey: "iCloudSync")
            if contentTextView.text == placeholderString {
                record.setValue("", forKey: "content")
            } else {
                record.setValue(contentTextView.text, forKey: "content")
            }
            record.setValue("0", forKey: "review")
            record.setValue("1", forKey: "notebookid")
            
            if isSetPhoto {
                let diaryImage = photoImageView.image!
                // Resize the image
                let imageData = UIImagePNGRepresentation(diaryImage)!
                let originalImage = UIImage(data: imageData)!
                let scalingFator = (originalImage.size.width > 1024) ? 1024 / originalImage.size.width : 1.0
                let scaledImage = UIImage(data: imageData, scale: scalingFator)!
                
                // Write the image to the local file for temporary use
                let imageFilePath = NSTemporaryDirectory() + titleTextField.text!
                let imageFileURL = URL(fileURLWithPath: imageFilePath)
                try? UIImageJPEGRepresentation(scaledImage, 0.8)?.write(to: imageFileURL)
                
                // Create image asset for upload
                let imageAsset = CKAsset(fileURL: imageFileURL)
                
                record.setValue(imageAsset, forKey: "image")
                
                let privateDatabase = CKContainer.default().privateCloudDatabase
                privateDatabase.save(record, completionHandler: { (record, error) in
                    if let error = error {
                        // Insert error handling
                        self.recordName = ""
                        print("NewDiary SaveToCloudError: \(error.localizedDescription)")
                        return
                    }
                    // Insert successfully saved record code
                    print("Saving data to iCloud")
                    try? FileManager.default.removeItem(at: imageFileURL)
                })
            } else {
                let privateDatabase = CKContainer.default().privateCloudDatabase
                privateDatabase.save(record, completionHandler: { (record, error) in
                    if let error = error {
                        // Insert error handling
                        print("NewDiary SaveToCloudError: \(error.localizedDescription)")
                        self.recordName = ""
                        return
                    }
                    // Insert successfully saved record code
                    print("Saving data to iCloud")
                })
            }
            
            // Save to CoreData
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                diary = DiaryMO(context: context)
                
                diary.id = dataId
                diary.recordName = self.recordName
                diary.title = titleTextField.text
                if tagButton.titleLabel?.text == "tag" {
                    diary.tag = ""
                } else {
                    diary.tag = tagButton.titleLabel?.text
                }
                diary.weather = self.choosedWeatherButtonText
                if isGetUserLocation {
                    diary.location = self.userCurrentLocation
                } else {
                    diary.location = ""
                }
                
                diary.create = currentDate
                diary.update = currentDate
                if contentTextView.text == placeholderString {
                    diary.content = ""
                } else {
                    diary.content = contentTextView.text
                }
                
                diary.review = "0"
                diary.notebookid = String(UserDefaults.standard.integer(forKey: "defaultNoteBookId"))
                
                if isSetPhoto {
                    if let diaryImage = photoImageView.image {
                        let imageName = String(Int(round(Date.init().timeIntervalSince1970))) + randomString(length: 6) + "-image.jpg"
                        let imageStore = ImageStore(name: imageName)
                        if imageStore.storeImage(image: diaryImage) {
                            diary.image = imageName
                        }
                    }
                }
                
                defaults.setValue(diary.title, forKey: "title")
                defaults.setValue(diary.content, forKey: "content")
                
                print("Saving data to context")
                appDelegate.saveContext()
            }
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBOutlet var titleTextField: UITextField!
    
    @IBOutlet var photoImageView: UIImageView!
    
    @IBOutlet var contentTextView: UITextView!
    
    @IBOutlet weak var weatherButton: UIButton!
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet weak var tagButton: UIButton!
    
    @IBOutlet var locationImageView: UIImageView!
    
    @IBOutlet weak var locationButton: UIButton!
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        if CLLocationManager.authorizationStatus().rawValue < 3 {
            let alertController = UIAlertController (title: nil, message: NSLocalizedString("Location Settings", comment: "Location Settings"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Setting", comment: "Setting"), style: .default) { (alertAction) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            })
            
            present(alertController, animated: true, completion: nil)
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            locationButton.setTitle(NSLocalizedString("click to grant the access for location", comment: "click to grant the access for location"), for: UIControlState.normal)
        }
    }
    
    @IBAction func chooseWeather(segue: UIStoryboardSegue) {
        if let choosedWeather = segue.identifier {
            self.weatherButton.imageView?.image = UIImage(named: choosedWeather)
            self.choosedWeatherButtonText = choosedWeather
        }
    }
    
    @IBAction func closeWeather(segue: UIStoryboardSegue) {
        //self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeTags(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func chooseTag(segue: UIStoryboardSegue) {
        if let source = segue.source as? TagsTableViewController {
            if source.choosedTags.count > 0 {
                var tagString = ""
                for tag in source.choosedTags {
                    tagString = tagString + tag + " "
                }
                tagString.remove(at: tagString.index(before: tagString.endIndex))
                tagButton.setTitle(tagString, for: UIControlState.normal)
            } else {
                tagButton.setTitle("tag", for: UIControlState.normal)
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        tableView.separatorStyle = .none
        contentTextView.delegate = self

        // Configure navigation bar appearance
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)]
        contentTextView.text = placeholderString
        contentTextView.textColor = .lightGray
        titleTextField.placeholder = NSLocalizedString("Title", comment: "Title")
        currentDate = Date.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = NSLocalizedString("yyyy-MM-dd HH:mm:ss", comment: "yyyy-MM-dd HH:mm:ss")
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: currentDate)
        dateLabel.text = dateString
        
        self.choosedWeatherButtonText = "sunny"
        
        // Prepare to get user's location
        locationImageView.image = UIImage(named: "map")
        
        if CLLocationManager.authorizationStatus().rawValue < 3 {
            locationButton.setTitle(NSLocalizedString("click to grant the access for location", comment: "click to grant the access for location"), for: UIControlState.normal)
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            locationButton.setTitle(NSLocalizedString("click to grant the access for location", comment: "click to grant the access for location"), for: UIControlState.normal)
        }
        
        if UserDefaults.standard.bool(forKey: "isNewPhoto") {
            UserDefaults.standard.set(false, forKey: "isNewPhoto")
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == placeholderString)
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text == ""
        {
            textView.text = placeholderString
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
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
                popoverController.sourceView = photoImageView
                popoverController.sourceRect = photoImageView.bounds
            }
            
            present(photoSourceRequestController, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userCLLocation = locations[0]
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(userCLLocation, completionHandler: { (placemarks, error) in
            if let error = error {
                self.locationButton.setTitle(NSLocalizedString("Failed to get location, click to retrieve", comment: "Failed to get location, click to retrieve"), for: UIControlState.normal)
                self.isGetUserLocation = false
                print(error)
                return
            }
            if let placemarks = placemarks {
                let placemarkPostalAddress = placemarks[0].postalAddress!
                let postalAddress = placemarkPostalAddress.city + placemarkPostalAddress.subLocality + placemarkPostalAddress.street
                let userLocation = UserLocation(latitude: self.userCLLocation.coordinate.latitude, longitude: self.userCLLocation.coordinate.longitude, postalAddress: postalAddress)
                print("{\(self.userCLLocation.coordinate.latitude), \(self.userCLLocation.coordinate.longitude)}")
                let jsonEncoder = JSONEncoder()
                do {
                    let jsonData = try jsonEncoder.encode(userLocation)
                    self.userCurrentLocation = String(data: jsonData, encoding: .utf8)!
                    self.isGetUserLocation = true
                }
                catch {
                    print(error)
                }
                let locationString = postalAddress
                self.locationButton.setTitle(locationString, for: UIControlState.normal)
            }
        })
        manager.stopUpdatingLocation()
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
            
            photoImageView.image = selectedImage
            self.isSetPhoto = true
            photoImageView.contentMode = .scaleToFill
            photoImageView.clipsToBounds = true
        }
        
        let leadingConstraint = NSLayoutConstraint(item: photoImageView, attribute: .leading, relatedBy: .equal, toItem: photoImageView.superview, attribute: .leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(item: photoImageView, attribute: .trailing, relatedBy: .equal, toItem: photoImageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
        let topConstraint = NSLayoutConstraint(item: photoImageView, attribute: .top, relatedBy: .equal, toItem: photoImageView.superview, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint = NSLayoutConstraint(item: photoImageView, attribute: .bottom, relatedBy: .equal, toItem: photoImageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
        
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTags" {
            let destination = segue.destination as! TagsTableViewController
            let tagButtonString = self.tagButton.titleLabel?.text ?? "tag"
            if tagButtonString != "tag" {
                let tagArray = tagButtonString.components(separatedBy: " ")
                destination.chooseTagsInit = tagArray
            }
        }
    }
}
