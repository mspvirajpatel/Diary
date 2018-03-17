
//
//  CloudDetailViewController.swift
//  Diary
//
//  Created by 牛苒 on 14/03/2018.
//  Copyright © 2018 牛苒. All rights reserved.
//

import UIKit
import CloudKit
import MapKit

class CloudDetailViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    var diary: CKRecord!
    private var imageCache = NSCache<CKRecordID, NSURL>()
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
    
    override var previewActionItems: [UIPreviewActionItem] {
        let cancelAction = UIPreviewAction.init(title: "Cancel", style: .destructive) { (action, viewController) in
            
        }
        return [cancelAction]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self
        navigationItem.largeTitleDisplayMode = .never
        fullImageView.image = UIImage(named: "photo")
        titleTextField.text = diary.object(forKey: "title") as? String
        let diaryTag = diary.object(forKey: "tag") as? String
        if let diaryTag = diaryTag {
            if diaryTag == "" {
                tagButton.setTitle("tag", for: UIControlState.normal)
            } else {
                tagButton.setTitle(diaryTag, for: UIControlState.normal)
            }
        } else {
            tagButton.setTitle("tag", for: UIControlState.normal)
        }
        
        // Check if the image is stored in cache
        if let imageFileURL = imageCache.object(forKey: diary.recordID) {
            // Fetch image from cache
            print("Get image from cache")
            if let imageData = try? Data.init(contentsOf: imageFileURL as URL) {
                fullImageView.image = UIImage(data: imageData)
            }
        } else {
            let privateDatabase = CKContainer.default().privateCloudDatabase
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
                            self.fullImageView.image = UIImage(data: imageData)
                        }
                    }
                }
            }
            privateDatabase.add(fetchRecordsImageOperation)
        }
        
        if let diaryWeather = diary.object(forKey: "weather") as? String {
            weatherImageView.image = UIImage(named: diaryWeather)
        }
        
        if let location = diary.object(forKey: "location") as? CLLocation {
            if location.coordinate.latitude == 0.0 && location.coordinate.longitude == 0.0 {
                locationButton.setTitle(NSLocalizedString("Locate failed", comment: "Locate failed"), for: UIControlState.normal)
            } else {
                let geoCoder = CLGeocoder()
                geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                    if let error = error {
                        self.locationButton.setTitle(NSLocalizedString("Locate failed", comment: "Locate failed"), for: UIControlState.normal)
                        print(error)
                    }
                    if let placemarks = placemarks {
                        let placemarkPostalAddress = placemarks[0].postalAddress!
                        let postalAddress = placemarkPostalAddress.city + placemarkPostalAddress.subLocality + placemarkPostalAddress.street
                        self.locationButton.setTitle(postalAddress, for: UIControlState.normal)
                    }
                })
            }
        } else {
            locationButton.setTitle(NSLocalizedString("Locate failed", comment: "Locate failed"), for: UIControlState.normal)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = NSLocalizedString("yyyy-MM-dd HH:mm:ss", comment: "yyyy-MM-dd HH:mm:ss")
        dateFormatter.timeZone = TimeZone.current
        
        dateLabel.text = dateFormatter.string(from: diary.object(forKey: "createdAt") as! Date)
        creatDateLabel.text = NSLocalizedString("createdAt", comment: "createdAt") + dateFormatter.string(from: diary.object(forKey: "createdAt") as! Date)
        updateDateLabel.text = NSLocalizedString("modifiedAt", comment: "modifiedAt") + dateFormatter.string(from: diary.object(forKey: "modifiedAt") as! Date)
        
        //        scrollView.contentInsetAdjustmentBehavior = .never
        
        contentTextView.text = diary.object(forKey: "content") as? String
        contentTextView.delegate = self
        contentTextView.sizeToFit()
        contentTextView.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hidesBottomBarWhenPushed = true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCloudMap" {
            let destinationController = segue.destination as! CloudMapViewController
            destinationController.diary = diary
        }
    }

}
