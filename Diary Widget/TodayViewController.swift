//
//  TodayViewController.swift
//  Diary Widget
//
//  Created by 牛苒 on 08/03/2018.
//  Copyright © 2018 牛苒. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var defaults = UserDefaults(suiteName: "group.com.niuran.diary")!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var remindLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        if let recentTitle = defaults.value(forKey: "title") as? String, let recentContent = defaults.value(forKey: "content") as? String {
            remindLabel.isHidden = true
            titleLabel.isHidden = false
            contentLabel.isHidden = false
            titleLabel.text = recentTitle
            contentLabel.text = recentContent
        } else {
            remindLabel.isHidden = false
            titleLabel.isHidden = true
            contentLabel.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        if let recentTitle = defaults.value(forKey: "title") as? String, let recentContent = defaults.value(forKey: "content") as? String {
            remindLabel.isHidden = true
            titleLabel.isHidden = false
            contentLabel.isHidden = false
            titleLabel.text = recentTitle
            contentLabel.text = recentContent
        } else {
            remindLabel.isHidden = false
            titleLabel.isHidden = true
            contentLabel.isHidden = true
        }
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
