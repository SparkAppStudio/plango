//
//  AppDelegate.swift
//  Plango
//
//  Created by Douglas Hewitt on 3/31/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import GoogleMaps
import FBSDKCoreKit
import FBSDKLoginKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GMSServices.provideAPIKey("AIzaSyA39ZWfxBR9I4VENEDuS53ivijYC_ZKvpY")
        // Override point for customization after application launch.        
        NSNotificationCenter.defaultCenter().addObserverForName(Notify.Login.rawValue, object: nil, queue: nil) { (notification) -> Void in
            self.appLogin(notification)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Notify.NewUser.rawValue, object: nil, queue: nil) { (notification) in
            self.appNewUser(notification)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Notify.Logout.rawValue, object: nil, queue: nil) { (notification) -> Void in
            self.appLogout(notification)
        }
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        configureTabController()
        syncAuthStatus()
        window?.makeKeyAndVisible()
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func presentEmailConfirmation(controller: UIViewController, email: String, error: PlangoError) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alert = UIAlertController(title: "Email Confirmation", message: error.message, preferredStyle: .Alert)
            let sendConfirmation = UIAlertAction(title: "Resend", style: .Default, handler: { (action) in
                //Plango send email
                Plango.sharedInstance.confirmEmail(Plango.EndPoint.SendConfirmation.rawValue, email: email, onCompletion: { (error) in
                    if let error = error {
                        controller.printPlangoError(error)
                        if let message = error.message {
                            controller.view.quickToast(message)
                        }
                        
                    } else {
                        controller.view.imageToast("Email Sent", image: UIImage(named: "whiteCheck")!, notify: false)
                    }
                })
            })
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in }
            alert.addAction(cancel)
            alert.addAction(sendConfirmation)
            
            controller.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func getParametersFromFacebook(result: AnyObject) -> [String:AnyObject] {
        var plangoParameters = [String:AnyObject]()
        var socialConnects = [[String:AnyObject]]()
        
        let email = result.valueForKey("email")
        let userName = result.valueForKey("name")?.lowercaseString
        let displayName = "\(result.valueForKey("first_name")) \(result.valueForKey("last_name"))"
        let userID = result.valueForKey("id")
        
        
        plangoParameters["email"] = email
        plangoParameters["username"] = userName!
        
        socialConnects.append(["network" : "Facebook", "socialId" : userID!, "displayName" : displayName, "email" : email!])
        
        plangoParameters["socialConnects"] = socialConnects
        plangoParameters["fbSignup"] = true
        return plangoParameters
    }
    
    func handlePlangoAuth(controller: UITableViewController, endPoint: String, email: String?, completionMessage: String?, parameters: [String:AnyObject]?) {
        Plango.sharedInstance.authPlangoUser(endPoint, parameters: parameters, onCompletion: { (user, error) in
            controller.tableView.hideSimpleLoading()
            
            if let error = error {
                controller.printPlangoError(error)
                if error.statusCode == 403 {
                    guard let email = email else {return}
                    self.presentEmailConfirmation(controller, email: email, error: error)
                } else {
                    if let message = error.message {
                        controller.tableView.quickToast(message)
                    }
                }
            } else if let user = user {
                Plango.sharedInstance.currentUser = user
                
                NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(user), forKey: UserDefaultsKeys.currentUser.rawValue)
                
                controller.tableView.imageToast(completionMessage, image: UIImage(named: "whiteCheck")!, notify: true)
                
            }
        })
    }
    
    func appNewUser(notification: NSNotification) {
        //every login notification should send controller so UI can be modified here loading screen etc.
        let controller = notification.userInfo!["controller"] as! UITableViewController
        controller.tableView.showSimpleLoading()
        
        //facebook newuser
        if let _ = notification.userInfo?["FBSDKLoginResult"] as? FBSDKLoginManagerLoginResult, userName = notification.userInfo?["userName"] as? String, let userEmail = notification.userInfo?["userEmail"] as? String, let userID = notification.userInfo?["userID"] as? String {
            
            var plangoParameters = [String:AnyObject]()
            var socialConnects = [[String:AnyObject]]()

            plangoParameters["email"] = userEmail
            plangoParameters["username"] = userName
            
            socialConnects.append(["network" : "Facebook", "socialId" : userID, "displayName" : userName, "email" : userEmail])
            
            plangoParameters["socialConnects"] = socialConnects
            plangoParameters["fbSignup"] = true

            self.handlePlangoAuth(controller, endPoint: Plango.EndPoint.NewAccount.rawValue, email: userEmail, completionMessage: nil, parameters: plangoParameters)

        }
        


        //email newuser
        if let userName = notification.userInfo?["userName"] as? String, let userEmail = notification.userInfo?["userEmail"] as? String, let password = notification.userInfo?["password"] as? String {
            
            let parameters = ["username" : userName, "email" : userEmail, "password" : password]
            
            self.handlePlangoAuth(controller, endPoint: Plango.EndPoint.NewAccount.rawValue, email: userEmail, completionMessage: "Check your Email", parameters: parameters)
            
        }
    }

    func appLogin(notification: NSNotification) {
        //every login notification should send controller so UI can be modified here loading screen etc.
        let controller = notification.userInfo!["controller"] as! LoginTableViewController
        controller.tableView.showSimpleLoading()

        //facebook login
        if let _ = notification.userInfo?["FBSDKLoginResult"] as? FBSDKLoginManagerLoginResult {
            
            let parameters = ["fields":"id, name, email"]
            FBSDKGraphRequest.init(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connection, result, error) in
                if let error = error {
                    controller.printError(error)
                } else {
//                    let email = result.valueForKey("email") as! String
                    let userID = result.valueForKey("id") as! String
                    
                    let endPoint = "\(Plango.EndPoint.FacebookLogin.rawValue)\(userID)"
                    self.handlePlangoAuth(controller, endPoint: endPoint, email: nil, completionMessage: nil, parameters: nil)

                }
            })
        //email login
        } else if let userEmail = notification.userInfo?["userEmail"] as? String, let password = notification.userInfo?["password"] as? String {
        
            let parameters = ["email" : userEmail, "password" : password]
            
            self.handlePlangoAuth(controller, endPoint: Plango.EndPoint.Login.rawValue, email: userEmail, completionMessage: nil, parameters: parameters)
        }
    }
    
    func appLogout(notification: NSNotification) {
        let controller = notification.userInfo!["controller"] as! UIViewController
        controller.view.showSimpleLoading()
        
        FBSDKLoginManager().logOut()

        Plango.sharedInstance.currentUser = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey(UserDefaultsKeys.currentUser.rawValue)
        
        Plango.sharedInstance.alamoManager.session.resetWithCompletionHandler {
            controller.view.hideSimpleLoading()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                controller.viewWillAppear(true)
            })
        }
    }
    
    func swapLoginControllerInTab() {
        //TODO: - if loggin out, set loginController as tabThree, if logging in set MyPlans as tabThree
    }
    
    func configureTabController() {
        let tabOne = UINavigationController(rootViewController: DiscoverTableViewController())
        
        let tabTwo = UINavigationController(rootViewController: SearchViewController())
        
        let tabThree = UINavigationController(rootViewController: MyPlansViewController())
        
//        let tabFour = UINavigationController(rootViewController: SettingsTableViewController())
        
        plangoNav([tabOne, tabTwo, tabThree])
        
        //search controllers
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.plangoOrange(), NSFontAttributeName: UIFont.plangoSmallButton()], forState: .Normal)
        
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).font = UIFont.plangoBody()
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).textColor = UIColor.plangoTextLight()
        
        
        let tabController = UITabBarController()
        tabController.viewControllers = [tabOne, tabTwo, tabThree]
        tabController.tabBar.barTintColor = UIColor.whiteColor()
        tabController.tabBar.backgroundColor = UIColor.whiteColor()
        tabController.tabBar.tintColor = UIColor.plangoTeal()
        tabController.tabBar.opaque = true
        
        let starImage = UIImage(named: "star")
        let searchImage = UIImage(named: "search")
        let myImage = UIImage(named: "my")
//        let gearImage = UIImage(named: "gear")

        tabOne.tabBarItem = UITabBarItem(title: "DISCOVER", image: starImage, tag: 1)
        tabTwo.tabBarItem = UITabBarItem(title: "SEARCH", image: searchImage, tag: 2)
        tabThree.tabBarItem = UITabBarItem(title: "MY PLANS", image: myImage, tag: 3)
//        tabFour.tabBarItem = UITabBarItem(title: "SETTINGS", image: gearImage, tag: 4)
        
        plangoTabBarItem([tabOne.tabBarItem, tabTwo.tabBarItem, tabThree.tabBarItem])
        
        window?.rootViewController = tabController
    }
    
    func syncAuthStatus() {
        if let userData = NSUserDefaults.standardUserDefaults().objectForKey(UserDefaultsKeys.currentUser.rawValue) as? NSData {
            let user = NSKeyedUnarchiver.unarchiveObjectWithData(userData) as! User
            Plango.sharedInstance.currentUser = user
        }
        
        if Plango.sharedInstance.alamoManager.session.configuration.HTTPCookieStorage?.cookies == nil && Plango.sharedInstance.currentUser != nil {
            Plango.sharedInstance.currentUser = nil
        }
        
        if Plango.sharedInstance.currentUser == nil && Plango.sharedInstance.alamoManager.session.configuration.HTTPCookieStorage?.cookies != nil {
            Plango.sharedInstance.alamoManager.session.resetWithCompletionHandler({})
        }
    }
    
//    func handleAuth() {
//        
//        
//        if Plango.sharedInstance.currentUser == nil {
//            
//
//        } else {
//            
//        }
//    }
    
    func plangoTabBarItem(tabBarItems: [UITabBarItem]) {
        for tab in tabBarItems {
            tab.setTitleTextAttributes([NSFontAttributeName: UIFont.plangoTabBar()], forState: .Normal)
        }
    }
    
    func plangoNav(navControllers: [UINavigationController]) {
        for nav in navControllers {
            nav.navigationBar.barTintColor = UIColor.plangoTeal()
            nav.navigationBar.tintColor = UIColor.whiteColor()
            nav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.plangoNav()]
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
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

