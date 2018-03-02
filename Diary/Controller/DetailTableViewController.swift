//
//  DetailViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/22.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import CoreData

class DetailTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    var diary: DiaryMO!
    var fetchDiary: DiaryMO!
    var fetchResultController: NSFetchedResultsController<DiaryMO>!
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var fullImageView: UIImageView!
    @IBOutlet var tagLabel: UILabel! {
        didSet {
            tagLabel.layer.cornerRadius = 5.0
            tagLabel.layer.masksToBounds = true
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
    
    var doneButton = UIButton()
    var textViewStartString = ""
    var textViewEndString = ""
    var textFieldStartString = ""
    var textFieldEndString = ""
    
    @objc func buttonClick(_ sender: UIButton) {
        view.endEditing(true)
        
        if textFieldStartString != textFieldEndString || textViewStartString != textViewEndString {
            let currentDate = Date.init()
            // update data from data store - Diary
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest: NSFetchRequest<DiaryMO> = DiaryMO.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", diary.id!)
                
                do {
                    let results = try context.fetch(fetchRequest)
                    fetchRequest.returnsObjectsAsFaults = false
                    print("Results Count :", results.count)
                    
                    if(results.count > 0 ){
                        if textFieldStartString != textFieldEndString {
                            results[0].setValue(titleTextField.text, forKey: "title")
                        }
                        if textViewStartString != textViewEndString {
                            results[0].setValue(contentTextView.text, forKey: "content")
                        }
                        results[0].setValue(currentDate.timeIntervalSince1970, forKey: "update")
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
            dateFormatter.dateFormat = "yyyy年MM月dd日 H:m:s"
            dateFormatter.timeZone = TimeZone.current
            self.updateDateLabel.text = "修改于" + dateFormatter.string(from: currentDate)
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
        
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        navigationItem.largeTitleDisplayMode = .never
        
        // Json Decode the location information
        let jsonDecoder = JSONDecoder()
        if let location = diary.location {
            if let jsonData = location.data(using: .utf8) {
                do {
                    let userLocation = try jsonDecoder.decode(UserLocation.self, from: jsonData)
                    locationButton.setTitle(userLocation.city + userLocation.subLocality + userLocation.street, for: UIControlState.normal)
                } catch {
                    locationButton.setTitle("无", for: UIControlState.normal)
                    print(error)
                }
            }
        } else {
            locationButton.setTitle("无", for: UIControlState.normal)
        }
        
        titleTextField.text = diary.title
        titleTextField.delegate = self
        tagLabel.text = diary.tag
        fullImageView.image = UIImage(data: diary.image!)
        avatarImageView.image = UIImage(named: "avatar-man-stubble")
        authorLabel.text = diary.author
        weatherImageView.image = UIImage(named: diary.weather!)
        weatherLabel.text = diary.weather
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 H:m:s"
        dateFormatter.timeZone = TimeZone.current
        
        creatDateLabel.text = "创建于" + dateFormatter.string(from: Date.init(timeIntervalSince1970: diary.create))
        updateDateLabel.text = "修改于" + dateFormatter.string(from: Date.init(timeIntervalSince1970: diary.update))
        
        locationIconImageView.image = UIImage(named: "map")
        
        contentTextView.text = diary.content
        contentTextView.delegate = self
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
        textViewStartString = contentTextView.text
//        print(textViewStartString)
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        textViewEndString = contentTextView.text
//        print(textViewEndString)
        textView.resignFirstResponder()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let destinationController = segue.destination as! MapViewController
            destinationController.diary = diary
        }
    }

}
