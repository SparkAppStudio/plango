//
//  AppDelegate.swift
//  Plango
//
//  Created by Douglas Hewitt on 3/31/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
//import GoogleMaps
import GooglePlaces
import FBSDKCoreKit
import FBSDKLoginKit
import RealmSwift
import Mapbox
//import AlamofireImage


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
//        GMSServices.provideAPIKey("AIzaSyA39ZWfxBR9I4VENEDuS53ivijYC_ZKvpY")
        GMSPlacesClient.provideAPIKey("AIzaSyA39ZWfxBR9I4VENEDuS53ivijYC_ZKvpY")
        // Override point for customization after application launch.        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Notify.Login.rawValue), object: nil, queue: nil) { (notification) -> Void in
            self.appLogin(notification)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Notify.NewUser.rawValue), object: nil, queue: nil) { (notification) in
            self.appNewUser(notification)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Notify.Logout.rawValue), object: nil, queue: nil) { (notification) -> Void in
            self.appLogout(notification)
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        configureTabController()
        syncAuthStatus()
        window?.makeKeyAndVisible()
        
//        let diskCapacity = 1000 * 1024 * 1024
//        let diskCache = NSURLCache(memoryCapacity: 0, diskCapacity: diskCapacity, diskPath: "com.alamofire.imagedownloader")
//        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//        configuration.URLCache = diskCache
//        
//        let downloader = ImageDownloader(
//            configuration: configuration,
//            downloadPrioritization: .FIFO,
//            maximumActiveDownloads: 10,
//            imageCache: Plango.sharedInstance.photoCache
//        )
//
//        
//        UIImageView.af_sharedImageDownloader = downloader

        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func presentEmailConfirmation(_ controller: UIViewController, email: String, error: PlangoError) {
        DispatchQueue.main.async(execute: { () -> Void in
            let alert = UIAlertController(title: "Email Confirmation", message: error.message, preferredStyle: .alert)
            let sendConfirmation = UIAlertAction(title: "Resend", style: .default, handler: { (action) in
                //Plango send email
                Plango.sharedInstance.confirmEmail(Plango.EndPoint.SendConfirmation.value, email: email, onCompletion: { (error) in
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
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
            alert.addAction(cancel)
            alert.addAction(sendConfirmation)
            
            controller.present(alert, animated: true, completion: nil)
        })
    }
    
    func presentWelcome(_ controller: UIViewController, completionMessage: String?) {
        DispatchQueue.main.async(execute: { () -> Void in
            let alert = UIAlertController(title: "Welcome to Plango!", message: "We sent you an email to confirm your account. Click the link and then you can log in.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                controller.view.imageToast(completionMessage, image: UIImage(named: "whiteCheck")!, notify: true)
            })
            
            alert.addAction(ok)
            controller.present(alert, animated: true, completion: nil)
        })
    }
    
    func getParametersFromFacebook(_ result: AnyObject) -> [String:AnyObject] {
        var plangoParameters = [String:AnyObject]()
        var socialConnects = [[String:AnyObject]]()
        
        let email = result.value(forKey: "email")
        let userName = (result.value(forKey: "name") as AnyObject).lowercased
        let displayName = "\(result.value(forKey: "first_name")) \(result.value(forKey: "last_name"))"
        let userID = result.value(forKey: "id")
        
        
        plangoParameters["email"] = email as AnyObject?
        plangoParameters["username"] = userName! as AnyObject?
        
        socialConnects.append(["network" : "Facebook" as AnyObject, "socialId" : userID! as AnyObject, "displayName" : displayName as AnyObject, "email" : email! as AnyObject])
        
        plangoParameters["socialConnects"] = socialConnects as AnyObject?
        plangoParameters["fbSignup"] = true as AnyObject?
        return plangoParameters
    }
    
    func handlePlangoAuth(_ controller: UIViewController, endPoint: String, email: String?, completionMessage: String?, parameters: [String:AnyObject]?) {
        Plango.sharedInstance.authPlangoUser(endPoint, parameters: parameters, onCompletion: { (user, error) in
            controller.view.hideSimpleLoading()
            
            if let error = error {
                controller.printPlangoError(error)
                
                
                //do not perform this check if its the ConfirmVC, it would break account creation after user made minor mistake, such as already taken user name, instead log out of FB when user presses the cancel button on that controller
                if controller.classForCoder != LoginConfirmViewController.classForCoder() {
                    
                    //When trying to log in, it should log out user from facebook in any event because plango auth failed. Prevents state where user goes to login with facebook again and must "log out of facebook" first
                    FBSDKLoginManager().logOut()
                }

                
                if error.statusCode == 403 {
                    guard let email = email else {return}
                    self.presentEmailConfirmation(controller, email: email, error: error)
                } else if error.statusCode == 401 {
                    guard let message = error.message else {return}
                    controller.view.detailToast("", details: message)
                } else {
                    guard let message = error.message else {return}
                    controller.view.detailToast("", details: message)
                }
            } else if let user = user {
                Plango.sharedInstance.currentUser = user
                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: user), forKey: UserDefaultsKeys.currentUser.rawValue)
                if user.confirmed == false {
                    self.presentWelcome(controller, completionMessage: completionMessage)
                } else {
                    controller.view.imageToast(completionMessage, image: UIImage(named: "whiteCheck")!, notify: true)
                }
            }
        })
    }
    
    func appNewUser(_ notification: Foundation.Notification) {
        //every login notification should send controller so UI can be modified here loading screen etc.
        let controller = notification.userInfo!["controller"] as! LoginViewController
        controller.view.showSimpleLoading()
        
        //facebook newuser
        if let _ = notification.userInfo?["FBSDKLoginResult"] as? FBSDKLoginManagerLoginResult, let userName = notification.userInfo?["userName"] as? String, let userEmail = notification.userInfo?["userEmail"] as? String, let userID = notification.userInfo?["userID"] as? String {
            
            var plangoParameters = [String:AnyObject]()
            var socialConnects = [[String:AnyObject]]()
            
//            Plango.sharedInstance.facebookAvatarURL = "http://graph.facebook.com/\(userID)/picture?type=large"

            plangoParameters["email"] = userEmail as AnyObject?
            plangoParameters["username"] = userName as AnyObject?
            
            socialConnects.append(["network" : "Facebook" as AnyObject, "socialId" : userID as AnyObject, "displayName" : userName as AnyObject, "email" : userEmail as AnyObject])
            
            plangoParameters["socialConnects"] = socialConnects as AnyObject?
            plangoParameters["fbSignup"] = true as AnyObject?
            
            self.handlePlangoAuth(controller, endPoint: Plango.EndPoint.NewAccount.value, email: userEmail, completionMessage: nil, parameters: plangoParameters)

        }

        //email newuser
        if let userName = notification.userInfo?["userName"] as? String, let userEmail = notification.userInfo?["userEmail"] as? String, let password = notification.userInfo?["password"] as? String {
            
            let parameters = ["username" : userName, "email" : userEmail, "password" : password]
            
            self.handlePlangoAuth(controller, endPoint: Plango.EndPoint.NewAccount.value, email: userEmail, completionMessage: "Check your Email", parameters: parameters as [String : AnyObject]?)
            
        }
    }

    func appLogin(_ notification: Foundation.Notification) {
        //every login notification should send controller so UI can be modified here loading screen etc.
        let controller = notification.userInfo!["controller"] as! LoginViewController
        controller.view.showSimpleLoading()

        //facebook login
        if let _ = notification.userInfo?["FBSDKLoginResult"] as? FBSDKLoginManagerLoginResult {
            
            let parameters = ["fields":"id, name, email"]
            FBSDKGraphRequest.init(graphPath: "me", parameters: parameters).start(completionHandler: { (connection, result, error) in
                if let error = error {
                    controller.printError(error as NSError)
                } else {
//                    let email = result.valueForKey("email") as! String
                    let userID = result.value(forKey: "id") as! String
//                    Plango.sharedInstance.facebookAvatarURL = "http://graph.facebook.com/\(userID)/picture?type=large"

                    let endPoint = "\(Plango.EndPoint.FacebookLogin.value)\(userID)"
                    self.handlePlangoAuth(controller, endPoint: endPoint, email: nil, completionMessage: nil, parameters: nil)

                }
            })
        //email login
        } else if let userEmail = notification.userInfo?["userEmail"] as? String, let password = notification.userInfo?["password"] as? String {
        
            let parameters = ["email" : userEmail, "password" : password]
            
            self.handlePlangoAuth(controller, endPoint: Plango.EndPoint.Login.value, email: userEmail, completionMessage: nil, parameters: parameters as [String : AnyObject]?)
        }
    }
    
    func appLogout(_ notification: Foundation.Notification) {
        let controller = notification.userInfo!["controller"] as! UIViewController
        controller.view.showSimpleLoading()
        
        FBSDKLoginManager().logOut()

        Plango.sharedInstance.currentUser = nil
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.currentUser.rawValue)
//        Plango.sharedInstance.facebookAvatarURL = ""
        //remove realm data
        let realm = try! Realm()

        try! realm.write {
            realm.deleteAll()
        }
        
        //remove mapbox data
        let storage = MGLOfflineStorage.shared()
        if let packs = storage.packs {
            for pack in packs {
                storage.removePack(pack, withCompletionHandler: nil)
            }
        }

        
        Plango.sharedInstance.alamoManager.session.reset {
            controller.view.hideSimpleLoading()
            DispatchQueue.main.async(execute: { () -> Void in
                self.swapLoginControllerInTab()
            })
        }
    }
    
    func swapLoginControllerInTab() {

        let tabController = window!.rootViewController as! UITabBarController
        let nav = tabController.viewControllers?.last as! UINavigationController
        if Plango.sharedInstance.currentUser == nil {
            nav.setViewControllers([LoginCoverViewController()], animated: false)
            nav.isNavigationBarHidden = true
        } else {
            nav.setViewControllers([MyPlansViewController()], animated: false)
            nav.isNavigationBarHidden = false
        }
    }
    
    func configureTabController() {
        let tabOne = UINavigationController(rootViewController: DiscoverTableViewController())
        
        let tabTwo = UINavigationController(rootViewController: SearchViewController())
        
        let tabThree = UINavigationController(rootViewController: MyPlansViewController())
        
//        let tabFour = UINavigationController(rootViewController: SettingsTableViewController())
        
        plangoNav([tabOne, tabTwo, tabThree])
        
        //search controllers
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.plangoOrange(), NSFontAttributeName: UIFont.plangoSmallButton()], for: UIControlState())
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont.plangoBody()
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.plangoTextLight()
        
        
        let tabController = UITabBarController()
        tabController.viewControllers = [tabOne, tabTwo, tabThree]
        tabController.tabBar.barTintColor = UIColor.white
        tabController.tabBar.backgroundColor = UIColor.white
        tabController.tabBar.tintColor = UIColor.plangoTeal()
        tabController.tabBar.isOpaque = true
        
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
        if let userData = UserDefaults.standard.object(forKey: UserDefaultsKeys.currentUser.rawValue) as? Data {
            let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as! User
            Plango.sharedInstance.currentUser = user
        }
        
        if Plango.sharedInstance.alamoManager.session.configuration.httpCookieStorage?.cookies == nil && Plango.sharedInstance.currentUser != nil {
            Plango.sharedInstance.currentUser = nil
            
            swapLoginControllerInTab()
        }
        
        if Plango.sharedInstance.currentUser == nil && Plango.sharedInstance.alamoManager.session.configuration.httpCookieStorage?.cookies != nil {
            Plango.sharedInstance.alamoManager.session.reset(completionHandler: {})
            
            swapLoginControllerInTab()
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
    
    func plangoTabBarItem(_ tabBarItems: [UITabBarItem]) {
        for tab in tabBarItems {
            tab.setTitleTextAttributes([NSFontAttributeName: UIFont.plangoTabBar()], for: UIControlState())
        }
    }
    
    func plangoNav(_ navControllers: [UINavigationController]) {
        for nav in navControllers {
            nav.navigationBar.barTintColor = UIColor.plangoTeal()
            nav.navigationBar.tintColor = UIColor.white
            nav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.plangoNav()]
            nav.navigationBar.isTranslucent = false
        }
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

