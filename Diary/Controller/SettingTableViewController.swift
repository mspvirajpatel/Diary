//
//  SettingTableViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/3/5.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import LocalAuthentication
import NotificationCenter

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var syncDate: UILabel!
    @IBOutlet weak var FaceIDSwitch: UISwitch!
    
    
    @IBAction func changedFaceIDSwitch(_ sender: UISwitch) {
        // Get the local authentication context.
        let localAuthContext = LAContext()
        let resonText = "Authentication is required"
        var authError: NSError?
        if !localAuthContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            if let error = authError {
                print(error.localizedDescription)
            }
            // if TouchID is not available
            return
        }
        
        // Perform the Biometric authentication
        localAuthContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: resonText) { (success, error) in
            // Failure workflow
            if !success {
                let alertController = UIAlertController(title: "设置失败",
                                                        message: nil, preferredStyle: .alert)
                //显示提示框
                self.present(alertController, animated: true, completion: {
                    self.FaceIDSwitch.isOn = !self.FaceIDSwitch.isOn
                })
                //两秒钟后自动消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil )
                }
                if let error = error {
                    switch error {
                    case LAError.authenticationFailed:
                        print("Authentication failed")
                    case LAError.passcodeNotSet:
                        print("Passcode not set")
                    case LAError.systemCancel:
                        print("Authentication was canceled by system")
                    case LAError.userCancel:
                        print("Authentication was canceled by the user")
                    case LAError.userFallback:
                        print("User tapped the fallback button (Enter Password).")
                    default:
                        print(error.localizedDescription)
                    }
                }
            } else {
                // Success workflow
                print("Successfully authenticated")
                UserDefaults.standard.set(sender.isOn, forKey: "isOpenFaceID")
                return
            }
        }
    }
    
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
        
        if UIDevice.current.iPhoneX {
            idLabel.text = "Face ID"
        } else {
            idLabel.text = "Touch ID"
        }
        
        let userDefaultsSyncDate = UserDefaults.standard.object(forKey: "iCloudSync") as! Date
        syncDate.text = getFriendlyDate(date: userDefaultsSyncDate)

        FaceIDSwitch.isOn = UserDefaults.standard.bool(forKey: "isOpenFaceID")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
}
