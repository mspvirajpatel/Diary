//
//  AuthViewController.swift
//  Diary
//
//  Created by 牛苒 on 11/03/2018.
//  Copyright © 2018 牛苒. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthViewController: UIViewController {

    @IBAction func reAuthButtonTapped(_ sender: UIButton) {
        authenticateWithBiometric()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        authenticateWithBiometric()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - Touch ID / Face ID
    func authenticateWithBiometric() {
        let localAuthContext = LAContext()
        let reasonText = "Authentication is required"
        
        // Perform the Biometric authentication
        localAuthContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonText) { (success, error) in
            // Failure workflow
            if !success {
                let alertController = UIAlertController(title: error?.localizedDescription,
                                                        message: nil, preferredStyle: .alert)
                //显示提示框
                self.present(alertController, animated: true, completion: nil)
                //两秒钟后自动消失
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
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
                UserDefaults.standard.set(false, forKey: "isShouldAuth")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

}
