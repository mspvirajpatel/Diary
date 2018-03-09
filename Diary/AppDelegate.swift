//
//  AppDelegate.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/21.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("didFinishLaunchingWithOptions")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("User notifications are allowed.")
            } else {
                print("User notifications are not allowed.")
            }
        }
        UNUserNotificationCenter.current().delegate = self
//        // Override point for customization after application launch.
//        let backButtonImage = UIImage(named: "back")
//        UINavigationBar.appearance().backIndicatorImage = backButtonImage
//        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonImage
//        UINavigationBar.appearance().tintColor = UIColor.black
        
        UIApplication.shared.statusBarStyle = .default
        
        // Customize the tab bar
//        UITabBar.appearance().tintColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
//        UITabBar.appearance().barTintColor = UIColor.black
        UITabBar.appearance().tintColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        UITabBar.appearance().barTintColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem: shortcutItem))
    }
    
    private func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        let shortcutType = shortcutItem.type
        guard let shortcutIdentifier = QuickAction(fullIdentifier: shortcutType) else {
            return false
        }
        guard let tabBarController = window?.rootViewController as? UITabBarController else {
            return false
        }
        switch shortcutIdentifier {
        case .OpenDiaries:
            tabBarController.selectedIndex = 0
        case .OpenDiscover:
            tabBarController.selectedIndex = 1
        case .NewDiary:
            if let navController = tabBarController.viewControllers?[0] {
                let diaryTableViewController = navController.childViewControllers[0]
                diaryTableViewController.performSegue(withIdentifier: "showNewDiary", sender: diaryTableViewController)
            } else {
                return false
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("----------- applicationWillResignActive -----------")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("----------- applicationDidEnterBackground -----------")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("----------- applicationWillEnterForeground -----------")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("----------- applicationDidBecomeActive -----------")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("----------- applicationWillTerminate -----------")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Diary")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

enum QuickAction: String {
    case OpenDiaries = "OpenDiary"
    case OpenDiscover = "OpenDiscover"
    case NewDiary = "NewDiary"
    init?(fullIdentifier: String) {
        guard let shortcutIdentifier = fullIdentifier.components(separatedBy: ".").last else {
            return nil
        }
        self.init(rawValue: shortcutIdentifier)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "diary.newDiaryAction" {
            guard let tabBarController = window?.rootViewController as? UITabBarController else {
                return
            }
            print("New a Diary from notify")
            if let navController = tabBarController.viewControllers?[0] {
                let diaryTableViewController = navController.childViewControllers[0]
                diaryTableViewController.performSegue(withIdentifier: "showNewDiary", sender: diaryTableViewController)
            }
        }
        completionHandler()
    }
}
