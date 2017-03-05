//
//  ItineraryViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import MXSegmentedPager
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    
    //derived dates when plan doesnt have info
    var minDate = Date()
    var maxDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = false
        self.edgesForExtendedLayout = UIRectEdge()
        self.navigationItem.title = "Itinerary".uppercased()
        
        let mapBarButton = UIBarButtonItem(image: UIImage(named: "map"), style: .plain, target: self, action: #selector(didTapMap))
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
        self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocation.down
        self.segmentedPager.segmentedControl.backgroundColor = UIColor.white
        self.segmentedPager.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.plangoTypeSectionHeaderGray(), NSFontAttributeName: UIFont.plangoHeader()]
        self.segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.plangoTypeSectionHeaderGray(), NSFontAttributeName: UIFont.plangoHeader()]
        self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyle.fullWidthStripe
        self.segmentedPager.segmentedControl.selectionIndicatorColor = UIColor.plangoOrange()
        
        // Register reuse page
//        segmentedPager.pager.registerClass(eventsTableViewController.tableView.classForCoder, forPageReuseIdentifier: PageID.Days.rawValue)
        
        guard let plan = plan else {return}
        
        //derive days from events
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.autoupdatingCurrent
        
        guard let events = plan.events else {return}
        
        //setup baseline dates, ideally only loops once and then breaks, but written this way in case first events dont have dates but subsequent ones do
        for event in events {
            guard let startDate = event.startDate else {continue}
            minDate = startDate as Date
            maxDate = startDate as Date
            break
        }
        
        //find actual min and max
        for event in events {
            guard let startDate = event.startDate else {continue}
            if startDate < minDate {
                self.minDate = startDate as Date
            }
            if startDate > maxDate {
                maxDate = startDate as Date
            }
        }
        
        var days = Int()
        
        let hours = (calendar as NSCalendar).components(.hour, from: minDate, to: maxDate, options: []).hour
        let exactDays: Double = Double(hours!) / Double(24)
        days = Int(ceil(exactDays))
        if days == 0 {
            days = 1
        }
        
        if plan.durationDays != nil && plan.durationDays != 0 {
            days = plan.durationDays
        }
        
        for item in 1...days {
            titlesArray.add("Day \(item)")
        }
    }
    
    func didTapMap() {
        let experiences = experiencesByDays[segmentedPager.pager.indexForSelectedPage]
        if experiences?.count > 0 {
            var hasMapData = false
            for exp in experiences! {
                if exp.geocode?.count == 2 {
                    hasMapData = true
                    break
                }
            }
            
            if hasMapData == true {
                displayMapForExperiences(experiences!, title: "Day \(segmentedPager.pager.indexForSelectedPage + 1)", download: false)
            } else {
                self.view.quickToast("No Map Data")
            }
            
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
    
    override func heightForSegmentedControl(in segmentedPager: MXSegmentedPager) -> CGFloat {
        return Helper.HeaderHeight.pager.value
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, didScrollWith parallaxHeader: MXParallaxHeader) {
        //use or override for refresh effect
    }
    
    
    // MARK: - MXSegmentedpagerDataSource
    
    override func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        if titlesArray.count == 0 {
            return 1
        } else {
            return titlesArray.count            
        }
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        if titlesArray.count == 0 {
            return "Unknown"
        } else {
            return titlesArray[index] as! String            
        }
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, viewControllerForPageAt index: Int) -> UIViewController {
        
        let eventsTableViewController = ItineraryTableViewController()
        
        self.addChildViewController(eventsTableViewController)
        eventsTableViewController.didMove(toParentViewController: self)

        guard let plan = plan else {return eventsTableViewController}
        guard let events = plan.events else {return eventsTableViewController}
        guard let experiences = plan.experiences else {return eventsTableViewController}

        var eventsForTheDay = [Event]()
        var experiencesForTheDay = [Experience]()

        var calendar = Calendar.current
        calendar.timeZone = TimeZone.autoupdatingCurrent
        
        var startDate = Date()
//        if plan.startDate != nil {
//            startDate = plan.startDate!
//        } else {
            startDate = minDate
//        }
        
        let indexDate = (calendar as NSCalendar).date(byAdding: .day, value: index, to: startDate, options: [])
        
        let indexDay = (calendar as NSCalendar).component(.day, from: indexDate!)
        
        for event in events {
            let eventDay = (calendar as NSCalendar).component(.day, from: event.startDate! as Date)
            
            if eventDay == indexDay {
                eventsForTheDay.append(event)
            }
        }
        
        
        //sort events chronologically
        eventsForTheDay.sort(by: { $0.startDate < $1.startDate })

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
