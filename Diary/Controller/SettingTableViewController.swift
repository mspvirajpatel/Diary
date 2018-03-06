//
//  SettingTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/3/5.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var syncDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true

        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.hidesBarsOnSwipe = false
        // Configure navigation bar appearance
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.shadowImage = nil
        tableView.tableFooterView = UIView()
        
        let userDefaultsSyncDate = UserDefaults.standard.object(forKey: "iCloudSync") as! Date
        syncDate.text = getFriendlyTime(date: userDefaultsSyncDate)
    }
}
