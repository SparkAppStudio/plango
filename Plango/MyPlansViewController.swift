//
//  MyPlansViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/7/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import MXSegmentedPager

class MyPlansViewController: MXSegmentedPagerController {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var headerView: UIView!
    lazy var titlesArray: NSMutableArray = {
        let titles = NSMutableArray()
        return titles
    }()
    lazy var controllersArray: NSMutableArray = {
        let controllers = NSMutableArray()
        return controllers
    }()
    lazy var plansController: PlansTableViewController = {
        let plansVC = PlansTableViewController()
        plansVC.plansEndPoint = Plango.EndPoint.MyPlans.value

        return plansVC
    }()
    
    //account login logout
    
    lazy var accountBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "LOGOUT", style: .Plain, target: self, action: #selector(didTapAccountButton))
        return button
    }()
    
    func didTapAccountButton() {
        
        let alert = UIAlertController(title: "Logout?", message: "If you log out you will remove all plans and maps stored on this phone.", preferredStyle: .Alert)
        
        let delete = UIAlertAction(title: "Logout", style: UIAlertActionStyle.Destructive) { (action) in

            if Plango.sharedInstance.currentUser == nil {
                let nav = UINavigationController(rootViewController: LoginViewController())
                nav.navigationBar.barTintColor = UIColor.plangoTeal()
                nav.navigationBar.tintColor = UIColor.whiteColor()
                nav.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
                nav.navigationBar.translucent = false
                
                self.presentViewController(nav, animated: true, completion: nil)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(Notify.Logout.rawValue, object: nil, userInfo: ["controller": self])
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = accountBarButton
        self.extendedLayoutIncludesOpaqueBars = false
        self.edgesForExtendedLayout = .None
        
        addPage("My Plans", controller: plansController)
        
        // Parallax Header
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "ProfileHeader", bundle: bundle)
        headerView = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        // Parallax Header
        self.segmentedPager.parallaxHeader.view = headerView
        self.segmentedPager.parallaxHeader.mode = MXParallaxHeaderMode.Fill;
        self.segmentedPager.parallaxHeader.height = Helper.CellHeight.wideScreen.value
        self.segmentedPager.parallaxHeader.minimumHeight = 0;
        
        // Segmented Control customization
//        self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
//        self.segmentedPager.segmentedControl.backgroundColor = UIColor.whiteColor()
//        self.segmentedPager.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkTextColor()];
//        self.segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.plangoTeal()]
//        self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
//        self.segmentedPager.segmentedControl.selectionIndicatorColor = UIColor.plangoOrange()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "MY PLANS".uppercaseString
        if let user = Plango.sharedInstance.currentUser {
            
            accountBarButton.title = "LOGOUT"
            
            if let name = user.displayName {
                userNameLabel.text = name
                userNameLabel.dropShadow()
                
//                self.navigationItem.title = "\(name.uppercaseString)'S PLANS"
            }
            avatarImageView.makeCircle()

            if let endPoint = user.avatar {
                let cleanURL = NSURL(string: Plango.sharedInstance.cleanEndPoint(endPoint))
                avatarImageView.af_setImageWithURL(cleanURL!)
            }
//            else if let facebook = user.facebookAvatar {
//                let cleanURL = NSURL(string: facebook)
//                avatarImageView.af_setImageWithURL(cleanURL!)
//            }
            
        } else {
            accountBarButton.title = "LOGIN"

            userNameLabel.text = nil
            avatarImageView.af_cancelImageRequest()
            avatarImageView.image = nil
            plansController.clearTable()
        }
    }
    
    func addPage(title: String, controller: UIViewController) {
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        titlesArray.addObject(title)
        controllersArray.addObject(controller)
        
    }
    
    // MARK: - Gesture Recognizers
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//
//    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
//        return true
//    }
    
    // MARK: - MXSegmentedPagerDelegate
    override func heightForSegmentedControlInSegmentedPager(segmentedPager: MXSegmentedPager) -> CGFloat {
        return 0
    }
    
    override func segmentedPager(segmentedPager: MXSegmentedPager, didScrollWithParallaxHeader parallaxHeader: MXParallaxHeader) {

        //no need to query if not logged in
        guard let _ = Plango.sharedInstance.currentUser else {return}
        
        //use or override for refresh effect

        if parallaxHeader.progress > 0.2 {
            plansController.getPlans() //this method checks if current user is there and that request is nill before activating
        }
    }
    
    // MARK: - MXSegmentedpagerDataSource
    override func numberOfPagesInSegmentedPager(segmentedPager: MXSegmentedPager) -> Int {
        return titlesArray.count
    }
    
    override func segmentedPager(segmentedPager: MXSegmentedPager, titleForSectionAtIndex index: Int) -> String {
        return titlesArray[index] as! String
    }
    
    override func segmentedPager(segmentedPager: MXSegmentedPager, viewControllerForPageAtIndex index: Int) -> UIViewController {
        return controllersArray[index] as! UIViewController
    }
}
