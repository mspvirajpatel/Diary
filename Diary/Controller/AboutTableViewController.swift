//
//  AboutTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/24.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import SafariServices
import StoreKit
import MessageUI

class AboutTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    @IBAction func closeReturnToAboutPage(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func sendEmailButtonTapped(_ sender: UIButton) {
        sendEmail()
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
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)]
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
                SKStoreReviewController.requestReview()
            }
            if indexPath.row == 1 {
                if let url = URL(string: "itms-apps:itunes.apple.com/cn/app/apple-store/id1357419968?mt=8&action=write-review") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            if indexPath.row == 2 {
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
                if indexPath.row == 2 {
                    destinationController.targetURL = "https://niuran.cn/feedback"
                }
            }
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["niuran1993@gmail.com"])
            mail.setSubject(NSLocalizedString("customer feedback", comment: "customer feedback"))
            var messageBody = "<p>" + NSLocalizedString("Please enter your feedback here.", comment: "Please enter your feedback here.") + "</p><p></p><br><br><div><table>"
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                messageBody = messageBody + "<tr><th>版本</th>&nbsp;<td>" + version + "." + buildVersion + "</td></tr>"
            }
            messageBody = messageBody + "</table></div>"
            
            mail.setMessageBody(messageBody, isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
            let alertController = UIAlertController(title: NSLocalizedString("Warning", comment: "Warning"), message: NSLocalizedString("Mail services are not available", comment: "Mail services are not available"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: "Done"), style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
