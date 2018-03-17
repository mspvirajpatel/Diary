//
//  WalkthroughPageViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/24.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

protocol WalkthroughViewControllerDelegate: class {
    func didUpdatePageIndex(currentIndex: Int)
}

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    weak var walkthroughDelegate: WalkthroughViewControllerDelegate?
    var pageHeadings:[String] = []
    var pageImages = ["onboarding-1", "onboarding-2", "onboarding-3"]
    var pageSubheadings: [String] = []
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the data source to itself
        dataSource = self
        delegate = self
        
        pageHeadings.append(NSLocalizedString("CREATE YOUR OWN DIARY OR NOTE", comment: "CREATE YOUR OWN DIARY OR NOTE"))
        pageHeadings.append(NSLocalizedString("SYNC YOUR NOTES TO iCloud", comment: "SYNC YOUR NOTES TO iCloud"))
        pageHeadings.append(NSLocalizedString("DISCOVER NOTES ON DIFFERENT DEVICES", comment: "DISCOVER NOTES ON DIFFERENT DEVICES"))
        
        pageSubheadings.append(NSLocalizedString("Write your favorite things and create your own diary or notebook", comment: "Write your favorite things and create your own diary or notebook"))
        pageSubheadings.append(NSLocalizedString("Sync your notes to iCloud automatically", comment: "Sync your notes to iCloud automatically"))
        pageSubheadings.append(NSLocalizedString("Find notes created on different devices", comment: "Find notes created on different devices"))
        
        // Create the first walkthrough screen
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first as? WalkthroughContentViewController {
                currentIndex = contentViewController.index
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: contentViewController.index)
            }
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        return contentViewController(at: index)
    }
    
    func contentViewController(at index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= pageHeadings.count {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController {
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.subheading = pageSubheadings[index]
            pageContentViewController.index = index
            
            return pageContentViewController
        }
        return nil
    }

    func forwardPage() {
        currentIndex += 1
        if let nextViewController = contentViewController(at: currentIndex) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}
