//
//  SearchViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/7/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import MXSegmentedPager

class SearchViewController: MXSegmentedPagerController, UITextFieldDelegate {

    @IBOutlet weak var selectedTagsLabel: UILabel!
    @IBOutlet weak var selectedDestinationsLabel: UILabel!
    @IBOutlet weak var selectedDurationLabel: UILabel!
    
    var minDuration: Int?
    var maxDuration: Int?
    var selectedTags: [Tag]?
    var selectedDestinations: [Destination]?
    
//    var headerView: UIView!
    
    lazy var titlesArray: NSMutableArray = {
        let titles = NSMutableArray()
        return titles
    }()
    lazy var controllersArray: NSMutableArray = {
        let controllers = NSMutableArray()
        return controllers
    }()
    lazy var destinationController: SearchDestinationViewController = {
        let destinationVC = SearchDestinationViewController()
        return destinationVC
    }()
    lazy var tagsController: SearchTagsViewController = {
        let tagsVC = SearchTagsViewController()
        return tagsVC
    }()
    lazy var durationController: SearchDurationViewController = {
        let tagsVC = SearchDurationViewController()
        return tagsVC
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPage("Tags", controller: tagsController)
        addPage("Destination", controller: destinationController)
        addPage("Duration", controller: durationController)
        
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
//        self.segmentedPager.parallaxHeader.contentView.backgroundColor = UIColor.plangoCream()
        
        self.segmentedPager.backgroundColor = UIColor.plangoCream()
        
        // Segmented Control customization
        self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        self.segmentedPager.segmentedControl.backgroundColor = UIColor.whiteColor()
        self.segmentedPager.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkTextColor()];
        self.segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.plangoTeal()]
        self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
        self.segmentedPager.segmentedControl.selectionIndicatorColor = UIColor.plangoOrange()
//        self.segmentedPager.segmentedControl.selectedSegmentIndex = 1
        
    }
    
    func collectSearchParameters() {
        if let min = durationController.selectedMin {
            minDuration = Int(min)
        }
        if let max = durationController.selectedMax {
            maxDuration = Int(max)
        }
        selectedTags = tagsController.selectedTags
        selectedDestinations = destinationController.selectedDestinations
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        searchButton.makeRoundCorners(64)
    }
    
    func addPage(title: String, controller: UIViewController) {
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        titlesArray.addObject(title)
        controllersArray.addObject(controller)
        
    }
    
    func displaySelections(tags: [Tag]?, destinations: [Destination]?, duration: Duration?) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let tags = tags {
                var allTags = "Selected Tags: "
                for item in tags {
                    guard let name = item.name else {return}
                    allTags.appendContentsOf("\(name), ")
                }
                let cleanedTags = String(allTags.characters.dropLast(2))
                self.selectedTagsLabel.text = cleanedTags
            }
            
            if let destinations = destinations {
                var allDestinations = "Selected Destinations: "
                for item in destinations {
                    if let city = item.city {
                        allDestinations.appendContentsOf("\(city), ")
                    } else if let state = item.state {
                        allDestinations.appendContentsOf("\(state), ")
                    } else if let country = item.country {
                        allDestinations.appendContentsOf("\(country), ")
                    }
                }
                let cleanedDestinations = String(allDestinations.characters.dropLast(2))
                self.selectedDestinationsLabel.text = cleanedDestinations
            }
            
            if let duration = duration {
                self.selectedDurationLabel.text = "Duration: \(duration.minimum) min \(duration.maximum) max"
            }
        })

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