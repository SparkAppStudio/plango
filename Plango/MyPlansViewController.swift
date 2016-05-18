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
        plansVC.plansEndPoint = Plango.EndPoint.MyPlans.rawValue
        return plansVC
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPage("My Plans", controller: plansController)
        
        // Parallax Header
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "ProfileHeader", bundle: bundle)
        headerView = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        // Parallax Header
        self.segmentedPager.parallaxHeader.view = headerView
        self.segmentedPager.parallaxHeader.mode = MXParallaxHeaderMode.Fill;
        self.segmentedPager.parallaxHeader.height = 180;
        self.segmentedPager.parallaxHeader.minimumHeight = 0;
        
        // Segmented Control customization
        self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        self.segmentedPager.segmentedControl.backgroundColor = UIColor.whiteColor()
        self.segmentedPager.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkTextColor()];
        self.segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.plangoTeal()]
        self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
        self.segmentedPager.segmentedControl.selectionIndicatorColor = UIColor.plangoOrange()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = Plango.sharedInstance.currentUser {
            if let name = user.displayName {
                userNameLabel.text = name
            }
            if let name = user.userName {
                userNameLabel.text = name
            }
            
            if let endPoint = user.avatar {
                let cleanURL = NSURL(string: Plango.sharedInstance.cleanEndPoint(endPoint))
                avatarImageView.af_setImageWithURL(cleanURL!)
            }
            
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
        return 30
    }
    
    override func segmentedPager(segmentedPager: MXSegmentedPager, didScrollWithParallaxHeader parallaxHeader: MXParallaxHeader) {
        //use or override for refresh effect
        if parallaxHeader.progress > 0.8 {
            plansController.fetchPlans(plansController.plansEndPoint)
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
