//
//  AppDelegate.swift
//  Plango
//
//  Created by Douglas Hewitt on 3/31/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.        
        NSNotificationCenter.defaultCenter().addObserverForName(Notify.Login.rawValue, object: nil, queue: nil) { (notification) -> Void in
            self.appLogin()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Notify.Logout.rawValue, object: nil, queue: nil) { (notification) -> Void in
            self.appLogout()
        }
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        handleAuth()
        window?.makeKeyAndVisible()
        return true
    }
    
    
    func appLogin() {
        handleAuth()
    }
    
    func appLogout() {
        handleAuth()
    }
    
    func handleAuth() {
//        let homeController = UIStoryboard(name: StoryboardID.Main.rawValue, bundle: nil).instantiateViewControllerWithIdentifier(ViewControllerID.Discover.rawValue)
        let tabOne = UINavigationController(rootViewController: DiscoverTableViewController())
        
        let searchController = UIStoryboard(name: StoryboardID.Utilities.rawValue, bundle: nil).instantiateViewControllerWithIdentifier(ViewControllerID.Search.rawValue)
        let tabTwo = UINavigationController(rootViewController: searchController)
        
        let myPlansController = MyPlansViewController()
        let tabThree = UINavigationController(rootViewController: myPlansController)
        
        let settingsController = SettingsTableViewController()
        let tabFour = UINavigationController(rootViewController: settingsController)
        
        plangoNav([tabOne, tabTwo, tabThree, tabFour])
        
        let tabController = UITabBarController()
        tabController.viewControllers = [tabOne, tabTwo, tabThree, tabFour]
        tabController.tabBar.barTintColor = UIColor.plangoCream()
        tabController.tabBar.tintColor = UIColor.plangoTeal()
        
        let starImage = UIImage(named: "star")
        let gearImage = UIImage(named: "gear")
        let myImage = UIImage(named: "my")
        let searchImage = UIImage(named: "search")
        
        tabOne.tabBarItem = UITabBarItem(title: "DISCOVER", image: starImage, tag: 1)
        tabTwo.tabBarItem = UITabBarItem(title: "SEARCH", image: searchImage, tag: 2)
        tabThree.tabBarItem = UITabBarItem(title: "MY PLANS", image: myImage, tag: 3)
        tabFour.tabBarItem = UITabBarItem(title: "SETTINGS", image: gearImage, tag: 4)

        
        if Plango.sharedInstance.currentUser == nil {
            //login root
//            window?.rootViewController = UIStoryboard(name: StoryboardID.Utilities.rawValue, bundle: nil).instantiateViewControllerWithIdentifier(ViewControllerID.Login.rawValue)
            
            window?.rootViewController = tabController

        } else {
            //main root
            window?.rootViewController = tabController
        }
    }
    
    func plangoNav(navControllers: [UINavigationController]) {
        for nav in navControllers {
            nav.navigationBar.barTintColor = UIColor.plangoTeal()
            nav.navigationBar.tintColor = UIColor.whiteColor()
            nav.navigationBar.translucent = false
        }
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

