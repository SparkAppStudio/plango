//
//  Search2ViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/19/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import GoogleMaps

class Search2ViewController: UIViewController, UISearchResultsUpdating {

//    lazy var resultsViewController: GMSAutocompleteResultsViewController = {
//       let resultsVC  = GMSAutocompleteResultsViewController()
//        resultsVC.delegate = self
//        return resultsVC
//    }()
    
//    var searchController: UISearchController?
    
//    var resultView: UITextView?
    
    var tags: [Tag]?
    
    var tagsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagsTableView = UITableView(frame: UIScreen.mainScreen().bounds)
        tagsTableView.delegate = self
        tagsTableView.dataSource = self
        tagsTableView.allowsMultipleSelection = true
        tagsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tag")
        self.view.addSubview(tagsTableView)
        
//        searchController = UISearchController(searchResultsController: resultsViewController)
//        searchController?.searchResultsUpdater = resultsViewController
//        
//        // Put the search bar in the navigation bar.
//        searchController?.searchBar.sizeToFit()
//        self.navigationItem.titleView = searchController?.searchBar
//        
//        // When UISearchController presents the results view, present it in
//        // this view controller, not one further up the chain.
//        self.definesPresentationContext = true
//        
//        // Prevent the navigation bar from being hidden when searching.
//        searchController?.hidesNavigationBarDuringPresentation = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Plango.sharedInstance.fetchTags(Plango.EndPoint.AllTags.rawValue) { (receivedTags, errorString) in
            if let error = errorString {
                print(error)
            } else if let tags = receivedTags {
                self.tags = tags
                self.tagsTableView.reloadData()
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String) {
        for tag in self.tags! {
            if searchText.lowercaseString.containsString(tag.name!) {
                //do something
            }
        }
        tagsTableView.reloadData()
    }
    
}

extension Search2ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tags = self.tags {
            return tags.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tag", forIndexPath: indexPath)
        cell.textLabel?.text = tags![indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
    }
}

// Handle the user's selection.
//extension Search2ViewController: GMSAutocompleteResultsViewControllerDelegate {
//    func resultsController(resultsController: GMSAutocompleteResultsViewController,
//                           didAutocompleteWithPlace place: GMSPlace) {
//        searchController?.active = false
//        // Do something with the selected place.
//        print("Place name: ", place.name)
//        print("Place address: ", place.formattedAddress)
//        print("Place attributions: ", place.attributions)
//        
//        var selectedPlace: [String:String] = [:]
//        
//        for item in place.addressComponents! {
//            if item.type == kGMSPlaceTypeLocality { //city
//                selectedPlace["city"] = item.name
//            } else if item.type == kGMSPlaceTypeAdministrativeAreaLevel1 { //state
//                selectedPlace["state"] = item.name
//            } else if item.type == kGMSPlaceTypeCountry { //country
//                selectedPlace["country"] = item.name
//            }
//        }
//        
//        let plansVC = PlansTableViewController()
//        plansVC.plansEndPoint = Plango.EndPoint.FindPlans.rawValue
//        
//        plansVC.findPlans(plansVC.plansEndPoint, durationFrom: nil, durationTo: nil, tags: nil, selectedPlaces: [selectedPlace], user: nil, isJapanSearch: nil)
//        
//        self.showViewController(plansVC, sender: nil)
//    }
//    
//    func resultsController(resultsController: GMSAutocompleteResultsViewController,
//                           didFailAutocompleteWithError error: NSError){
//        // TODO: handle the error.
//        print("Error: ", error.description)
//    }
//    
//    // Turn the network activity indicator on and off again.
//    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//    }
//    
//    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//    }
//}
