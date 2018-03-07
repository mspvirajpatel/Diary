//
//  NotifyTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/3/7.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import UserNotifications

class NotifyTableViewController: UITableViewController {
    
    @IBOutlet weak var isOpenNotifySwitch: UISwitch!
    
    @IBAction func tapToNotifySwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isOpenNotify")
        if sender.isOn == false {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["diary.diaryNotifyEveryday"])
            print("notify removed")
        }
        datePicker.isHidden = true
        tableView.reloadData()
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker! {
        didSet {
            datePicker.locale = Locale.current
        }
    }
    
    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
        timeLabel.text = dateFormatter.string(from: sender.date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        datePicker.isHidden = true
        isOpenNotifySwitch.isOn = UserDefaults.standard.bool(forKey: "isOpenNotify")
        let date = UserDefaults.standard.object(forKey: "notifyEverydayTime") as! Date
        datePicker.date = date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
        timeLabel.text = dateFormatter.string(from: date)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        if isOpenNotifySwitch.isOn {
            UserDefaults.standard.set(datePicker.date, forKey: "notifyEverydayTime")
            
            let content = UNMutableNotificationContent()
            content.title = "Diary Reminder"
            content.subtitle = "Write a Diary Today!"
            content.body = "Record what happend today."
            
            // Pick a image
//            let randomNum = Int(arc4random_uniform(UInt32(7)))
            let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            print(NSTemporaryDirectory())
            let tempFileURL = tempDirURL.appendingPathComponent("notify1.jpg")
            if let image = UIImage(named: "notify1.jpg") {
                try? UIImageJPEGRepresentation(image, 1.0)?.write(to: tempFileURL)
                if let notifyImage = try? UNNotificationAttachment(identifier: "notifyImage", url: tempFileURL, options: nil) {
                    content.attachments = [notifyImage]
                }
            }
            
            content.sound = UNNotificationSound.default()
            
            
            let dateFormatter = DateFormatter()
            var date = DateComponents()
            
            dateFormatter.dateFormat = "HH"
            dateFormatter.timeZone = TimeZone.current
            date.hour = Int(dateFormatter.string(from: datePicker.date))
            
            dateFormatter.dateFormat = "mm"
            dateFormatter.timeZone = TimeZone.current
            date.minute = Int(dateFormatter.string(from: datePicker.date))
            
            // Set categoryAction
            let categoryIdentifer = "diary.diaryNotifyEverydayAction"
            let newDiaryAction = UNNotificationAction(identifier: "diary.newDiaryAction", title: "New a Diary", options: [.foreground])
            let cancelAction = UNNotificationAction(identifier: "diary.cancel", title: "Later", options: [])
            let category = UNNotificationCategory(identifier: categoryIdentifer, actions: [newDiaryAction, cancelAction], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([category])
            content.categoryIdentifier = "diary.diaryNotifyEverydayAction"
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            let request = UNNotificationRequest(identifier: "diary.diaryNotifyEveryday", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print(error)
                } else {
                    print("diary.diaryNotifyEveryday added!")
                }
            })
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isOpenNotifySwitch.isOn {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            if datePicker.isHidden {
                return 1
            } else {
                return 2
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 {
                datePicker.isHidden = false
                tableView.reloadData()
            }
        default:
            break
        }
    }

}
