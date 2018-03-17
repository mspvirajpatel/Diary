//
//  WalkthroughViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/24.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController, WalkthroughViewControllerDelegate {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = 25.0
            nextButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var skipButton: UIButton!
    @IBAction func skipButtonTapped(sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
        createQuickActions()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func nextButtonTapped(sender: UIButton) {
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                walkthroughPageViewController?.forwardPage()
            case 2:
                UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
                createQuickActions()
                dismiss(animated: true, completion: nil)
            default:
                break
            }
        }
        
        updateUI()
    }
    var walkthroughPageViewController: WalkthroughPageViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        skipButton.setTitle(NSLocalizedString("Skip", comment: "Skip"), for: .normal)
        nextButton.setTitle(NSLocalizedString("NEXT", comment: "NEXT"), for: .normal)
        // Do any additional setup after loading the view.
    }
    
    func updateUI() {
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                nextButton.setTitle(NSLocalizedString("NEXT", comment: "NEXT"), for: .normal)
                skipButton.isHidden = false
            case 2:
                nextButton.setTitle(NSLocalizedString("GET STARTED", comment: "GET STARTED"), for: .normal)
                skipButton.isHidden = true
            default:
                break
            }
            
            pageControl.currentPage = index
        }
    }
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
    
    func createQuickActions() {
        // Add Quick Actions
        if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                let shortcutItem1 = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenDiaries", localizedTitle: "显示所有日记", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .home), userInfo: nil)
                let shortcutItem2 = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenDiscover", localizedTitle: "显示iCloud内容", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .favorite), userInfo: nil)
                let shortcutItem3 = UIApplicationShortcutItem(type: "\(bundleIdentifier).NewPhoto", localizedTitle: "拍照", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .capturePhoto), userInfo: nil)
                let shortcutItem4 = UIApplicationShortcutItem(type: "\(bundleIdentifier).NewDiary", localizedTitle: "新建日记", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
                UIApplication.shared.shortcutItems = [shortcutItem1, shortcutItem2, shortcutItem3, shortcutItem4]
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkthroughPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
}
