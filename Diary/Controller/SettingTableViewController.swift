//
//  SettingTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/3/5.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.hidesBarsOnSwipe = false
        // Configure navigation bar appearance
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        tableView.tableFooterView = UIView()
    }
}