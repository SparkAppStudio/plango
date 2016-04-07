//
//  AppDelegate.swift
//  Plango
//
//  Created by Douglas Hewitt on 3/31/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import ViewDeck

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
        
        handleAuth()

        return true
    }
    
    
    func appLogin() {
        handleAuth()
    }
    
    func appLogout() {
        handleAuth()
    }
    
    func handleAuth() {
        let homeController = UIStoryboard(name: StoryboardID.Main.rawValue, bundle: nil).instantiateViewControllerWithIdentifier(ViewControllerID.HomeMenu.rawValue)
        let centerController = UINavigationController(rootViewController: homeController)
        centerController.navigationBar.barTintColor = UIColor.plangoTeal()
        centerController.navigationBar.tintColor = UIColor.whiteColor()
        centerController.navigationBar.translucent = false
        let leftController = SideMenuTableViewController()
        let deckController = IIViewDeckController(centerViewController: centerController, leftViewController: leftController)
        deckController.leftSize = 100
        window?.rootViewController = deckController
        
//        if Twitter.sharedInstance().sessionStore.session() == nil {
//            //login root
//            window?.rootViewController = UIStoryboard(name: StoryboardID.Main.rawValue, bundle: nil).instantiateViewControllerWithIdentifier(ViewControllerID.Login.rawValue)
//        } else {
//            //main root
//            window?.rootViewController = UIStoryboard(name: StoryboardID.Main.rawValue, bundle: nil).instantiateViewControllerWithIdentifier(ViewControllerID.NavFeed.rawValue)
//            
//        }
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

