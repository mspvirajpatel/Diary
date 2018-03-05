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
    @IBOutlet var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.cornerRadius = 40.0
            avatarImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet var autherLabel: UILabel!
    @IBOutlet var userLevelLabel: UILabel!
    @IBOutlet weak var diaryNum: UIButton!
    @IBOutlet weak var favoriteNum: UIButton!
    @IBOutlet weak var followNum: UIButton!
    
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
        
        // Load user info
        if UserDefaults.standard.bool(forKey: "hasLogin") {
            avatarImageView.image = UIImage(named: "avatar-man-stubble")
        } else {
            avatarImageView.image = UIImage(named: "avatar-man-stubble")
            autherLabel.text = "未登录.."
            userLevelLabel.text = "匿名"
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                if UserDefaults.standard.bool(forKey: "hasLogin") {
                    performSegue(withIdentifier: "showUserCenter", sender: self)
                } else {
                    performSegue(withIdentifier: "showLoginPage", sender: self)
                }
            }
        case 2:
            if indexPath.row == 0 {
                if let url = URL(string: "https://www.apple.com/itues/charts/paid-apps/") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else if indexPath.row == 1 {
                performSegue(withIdentifier: "showWebView", sender: self)
            }
        case 3:
            if indexPath.row == 0 {
                if let url = URL(string: "https://niuran.cn") {
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
                if indexPath.row == 1 {
                    destinationController.targetURL = "https://niuran.cn/info"
                }
            }
        }
    }

}
