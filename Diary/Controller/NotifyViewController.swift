//
//  NotifyViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/3/7.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import UserNotifications

class NotifyViewController: UIViewController {

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
//        let content = UNMutableNotificationContent()
//        content.title = self.diary.title!
//        content.subtitle = self.diary.tag!
//        content.body = self.diary.content!
//        content.sound = UNNotificationSound.default()
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
//        let request = UNNotificationRequest(identifier: "diary.diaryNotify.", content: <#T##UNNotificationContent#>, trigger: <#T##UNNotificationTrigger?#>)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
