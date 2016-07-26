//
//  ItineraryViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import MXSegmentedPager

class ItineraryViewController: MXSegmentedPagerController {
    
    lazy var titlesArray: NSMutableArray = {
        let titles = NSMutableArray()
        return titles
    }()
//    lazy var controllersArray: NSMutableArray = {
//        let controllers = NSMutableArray()
//        return controllers
//    }()
//    lazy var eventsTableViewController: ItineraryTableViewController = {
//        let controller = ItineraryTableViewController()
//        return controller
//    }()
    
    var plan: Plan!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = false
        self.edgesForExtendedLayout = .None
        self.navigationItem.title = "Itinerary".uppercaseString
        
        let mapBarButton = UIBarButtonItem(image: UIImage(named: "map"), style: .Plain, target: self, action: #selector(didTapMap))
        self.navigationItem.rightBarButtonItem = mapBarButton
        
        // Parallax Header
        //        let bundle = NSBundle(forClass: self.dynamicType)
        //        let nib = UINib(nibName: "SearchHeader", bundle: bundle)
        //        headerView = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        //
        //        // Parallax Header
        //        self.segmentedPager.parallaxHeader.view = headerView
        //        self.segmentedPager.parallaxHeader.mode = MXParallaxHeaderMode.Bottom
        //        self.segmentedPager.parallaxHeader.height = 60;
        //        self.segmentedPager.parallaxHeader.minimumHeight = 0;
        //        self.segmentedPager.parallaxHeader.contentView.backgroundColor = UIColor.plangoBackgroundGray()
        
        self.segmentedPager.backgroundColor = UIColor.plangoBackgroundGray()
        
        // Segmented Control customization
        self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        self.segmentedPager.segmentedControl.backgroundColor = UIColor.whiteColor()
        self.segmentedPager.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.plangoTypeSectionHeaderGray(), NSFontAttributeName: UIFont.plangoHeader()]
        self.segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.plangoTypeSectionHeaderGray(), NSFontAttributeName: UIFont.plangoHeader()]
        self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
        self.segmentedPager.segmentedControl.selectionIndicatorColor = UIColor.plangoOrange()
        
        // Register reuse page
//        segmentedPager.pager.registerClass(eventsTableViewController.tableView.classForCoder, forPageReuseIdentifier: PageID.Days.rawValue)
        
        if let plan = plan {
            guard let days = plan.durationDays else {return}
            for item in 1...days {
//                addPage("Day \(item)", controller: eventsTableViewController)
                
                
                titlesArray.addObject("Day \(item)")
            }
        }
    }
    
    func didTapMap() {
        let experiences = experiencesByDays[segmentedPager.pager.indexForSelectedPage]
        if experiences?.count > 0 {
            displayMapForExperiences(experiences!, title: "Day \(segmentedPager.pager.indexForSelectedPage + 1)", download: false)
        } else {
            self.view.quickToast("No Experiences for Today")
        }
    }
    
//    func addPage(title: String, controller: UIViewController) {
//        self.addChildViewController(controller)
//        controller.didMoveToParentViewController(self)
//        titlesArray.addObject(title)
//        controllersArray.addObject(controller)
//        
//    }
    
    // MARK: - MXSegmentedPagerDelegate
    
    override func heightForSegmentedControlInSegmentedPager(segmentedPager: MXSegmentedPager) -> CGFloat {
        return Helper.HeaderHeight.pager.value
    }
    
    override func segmentedPager(segmentedPager: MXSegmentedPager, didScrollWithParallaxHeader parallaxHeader: MXParallaxHeader) {
        //use or override for refresh effect
    }
    
    
    // MARK: - MXSegmentedpagerDataSource
    
    override func numberOfPagesInSegmentedPager(segmentedPager: MXSegmentedPager) -> Int {
        if titlesArray.count == 0 {
            return 1
        } else {
            return titlesArray.count            
        }
    }
    
    override func segmentedPager(segmentedPager: MXSegmentedPager, titleForSectionAtIndex index: Int) -> String {
        if titlesArray.count == 0 {
            return "Unknown"
        } else {
            return titlesArray[index] as! String            
        }
    }
    
    override func segmentedPager(segmentedPager: MXSegmentedPager, viewControllerForPageAtIndex index: Int) -> UIViewController {
        
        let eventsTableViewController = ItineraryTableViewController()
        
        self.addChildViewController(eventsTableViewController)
        eventsTableViewController.didMoveToParentViewController(self)

        guard let plan = plan else {return eventsTableViewController}
        guard let events = plan.events else {return eventsTableViewController}
        guard let experiences = plan.experiences else {return eventsTableViewController}

        var eventsForTheDay = [Event]()
        var experiencesForTheDay = [Experience]()

        let calendar = NSCalendar.currentCalendar()
        calendar.timeZone = NSTimeZone.localTimeZone()
        let indexDate = calendar.dateByAddingUnit(.Day, value: index, toDate: plan.startDate!, options: [])
        
        let indexDay = calendar.component(.Day, fromDate: indexDate!)

        for event in events {
            let eventDay = calendar.component(.Day, fromDate: event.startDate!)
            
            if eventDay == indexDay {
                eventsForTheDay.append(event)
            }
        }

        for event in eventsForTheDay {
            for experience in experiences {
                if experience.id == event.experienceID {
                    experiencesForTheDay.append(experience)
                }
            }
        }
        
        eventsTableViewController.events = eventsForTheDay
        eventsTableViewController.experiences = experiencesForTheDay
        
        experiencesByDays[index] = experiencesForTheDay
        
        return eventsTableViewController
    }
    
    var experiencesByDays = [Int:[Experience]]()
    
//    override func segmentedPager(segmentedPager: MXSegmentedPager, viewForPageAtIndex index: Int) -> UIView {
//        let page = segmentedPager.pager.dequeueReusablePageWithIdentifier(PageID.Days.rawValue)!
//        
//        guard let plan = plan else {return page}
//        guard let events = plan.events else {return page}
//        guard let experiences = plan.experiences else {return page}
//        
//        var eventsForTheDay = [Event]()
//        var experiencesForTheDay = [Experience]()
//        
//        let calendar = NSCalendar.currentCalendar()
//        let indexDate = calendar.dateByAddingUnit(.Day, value: index - 1, toDate: plan.startDate!, options: [])
//        
//        for event in events {
//            if event.startDate == indexDate {
//                eventsForTheDay.append(event)
//            }
//        }
//        
//        for event in eventsForTheDay {
//            for experience in experiences {
//                if experience.id == event.experienceID {
//                    experiencesForTheDay.append(experience)
//                }
//            }
//        }
//        
//        eventsTableViewController.events = eventsForTheDay
//        eventsTableViewController.experiences = experiencesForTheDay
//        
//        return page
//    }

}
