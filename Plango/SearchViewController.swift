//
//  SearchViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/7/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import MXSegmentedPager
import GoogleMaps

class SearchViewController: MXSegmentedPagerController, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tagsButton: UIButton!
    @IBOutlet weak var durationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBAction func didTapSearch(sender: UIButton) {
        //        plansController.findPlans(plansController.plansEndPoint, durationFrom: 1, durationTo: 14, tags: nil, selectedPlaces: nil, user: nil, isJapanSearch: nil)
    }
    
    
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
        plansVC.plansEndPoint = Plango.EndPoint.FindPlans.rawValue
        return plansVC
    }()
    
    lazy var resultsViewController: GMSAutocompleteResultsViewController = {
        let resultsVC  = GMSAutocompleteResultsViewController()
        resultsVC.delegate = self
        return resultsVC
    }()
    
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPage("Search Results", controller: plansController)
        
        // Parallax Header
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "SearchHeader", bundle: bundle)
        headerView = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        // Parallax Header
        self.segmentedPager.parallaxHeader.view = headerView
        self.segmentedPager.parallaxHeader.mode = MXParallaxHeaderMode.Bottom
        self.segmentedPager.parallaxHeader.height = 180;
        self.segmentedPager.parallaxHeader.minimumHeight = 0;
        self.segmentedPager.parallaxHeader.contentView.backgroundColor = UIColor.plangoCream()
        
        // Segmented Control customization
        self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        self.segmentedPager.segmentedControl.backgroundColor = UIColor.whiteColor()
        self.segmentedPager.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkTextColor()];
        self.segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor.plangoTeal()]
        self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
        self.segmentedPager.segmentedControl.selectionIndicatorColor = UIColor.plangoOrange()
        
        
        //Search Controller
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        headerView.addSubview(searchController!.searchBar)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchButton.makeRoundCorners(64)
    }
    
    // MARK: - Text Field
    
    func processTextField(textField: UITextField) {
//        if let text = textField.text {
//            if text.characters.count > 0 {
//                if let currentProfile = self.profile {
//                    if let handle = currentProfile.handle {
//                        if handle != text {
//                            RVFirebaseUserProfile.lookUpProfileViaHandle(text, callback: { (error, userProfiles) -> Void in
//                                if let error = error {
//                                    error.printError("\(self.classForCoder)", method: "processTextField", message: nil)
//                                    
//                                } else if userProfiles.count == 0 {
//                                    currentProfile.handle = text
//                                    currentProfile.save({ (error, ref) -> (Void) in
//                                        self.view.quickToast("updated name")
//                                    })
//                                } else if userProfiles.count >= 1 {
//                                    self.view.quickToast("sorry name already taken")
//                                    
//                                }
//                            })
//                        }
//                    }
//                } else {
//                    print("In \(self.classForCoder).processTextField, no userProfile")
//                }
//                
//                
//            }
//        }
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        textField.layer.borderWidth = 0.0
        
        processTextField(textField)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        //enable tab
        if string == "\t" {
            textField.endEditing(true)
            return false
        }
        
        // method checks and sanitizes text for search
        if let textErrors = Helper.isValidSearchWithErrors(textField.text, possibleNewCharacter: string) {
            self.view.quickToast(textErrors)
            Helper.textIsValid(textField, sender: false)
            return false
        } else {
            // textErrors = nil so NO ERRORS proceed with text
            Helper.textIsValid(textField, sender: true)
            return true
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

// Handle the user's selection.
extension SearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        // Do something with the selected place.
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        
        var selectedPlace: [String:String] = [:]
        
        for item in place.addressComponents! {
            if item.type == kGMSPlaceTypeLocality { //city
                selectedPlace["city"] = item.name
            } else if item.type == kGMSPlaceTypeAdministrativeAreaLevel1 { //state
                selectedPlace["state"] = item.name
            } else if item.type == kGMSPlaceTypeCountry { //country
                selectedPlace["country"] = item.name
            }
        }
        
        let plansVC = PlansTableViewController()
        plansVC.plansEndPoint = Plango.EndPoint.FindPlans.rawValue
        
        plansVC.findPlans(plansVC.plansEndPoint, durationFrom: nil, durationTo: nil, tags: nil, selectedPlaces: [selectedPlace], user: nil, isJapanSearch: nil)
        
        self.showViewController(plansVC, sender: nil)
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: NSError){
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}