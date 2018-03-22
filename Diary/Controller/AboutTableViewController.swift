//
//  AboutTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/24.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import SafariServices

class AboutTableViewController: UITableViewController {
    @IBAction func closeReturnToAboutPage(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Configure navigation bar appearance
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)]
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure navigation bar appearance
        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)]
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            if indexPath.row == 0 {
                performSegue(withIdentifier: "showWebView", sender: self)
            }
        case 3:
            if indexPath.row == 0 {
                if let url = URL(string: "https://niuran.cn/diary") {
                    let safariController = SFSafariViewController(url: url)
                    present(safariController, animated: true, completion: nil)
                }
            }
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            if let destinationController = segue.destination as? WebViewController, let indexPath = tableView.indexPathForSelectedRow {
                if indexPath.row == 0 {
                    destinationController.targetURL = "https://niuran.cn/feedback"
                }
            }
        }
    }

}
