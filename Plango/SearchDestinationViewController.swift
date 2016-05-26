//
//  SearchDestinationViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/19/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import GoogleMaps

class SearchDestinationViewController: UIViewController {
    
    var searchController: UISearchController?
    
    var tableView: UITableView!
    
    var searchButton: UIButton!
    
    lazy var resultsViewController: GMSAutocompleteResultsViewController = {
       let resultsVC  = GMSAutocompleteResultsViewController()
        resultsVC.delegate = self
        return resultsVC
    }()
    
    var selectedDestinations = [Destination]() {
        didSet {
//            if let parent = parentViewController as? SearchViewController {
//                parent.displaySelections(nil, destinations: selectedDestinations, duration: nil)
//            }
//            self.tableView.reloadData()
        }
    }
    
    func didTapSearch(sender: UIButton) {
        if let parent = parentViewController as? SearchViewController {
            parent.collectSearchParameters()
            Plango.sharedInstance.findPlans(Plango.EndPoint.FindPlans.rawValue, minDuration: parent.minDuration, maxDuration: parent.maxDuration, tags: parent.selectedTags, selectedDestinations: parent.selectedDestinations, user: nil, isJapanSearch: nil, onCompletion: { (receivedPlans, errorString) in
                if let error = errorString {
                    print(error)
                } else if let plans = receivedPlans {
                    let plansVC = PlansTableViewController()
                    plansVC.plansArray = plans
                    self.showViewController(plansVC, sender: nil)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchButton = UIButton(type: .Custom)
        searchButton.titleLabel?.text = "Get Plans"
        searchButton.backgroundColor = UIColor.plangoOrange()
        searchButton.makeRoundCorners(32)
        searchButton.addTarget(self, action: #selector(didTapSearch), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(searchButton)
        
        searchButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        searchButton.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        searchButton.heightAnchor.constraintEqualToConstant(30)
        
        
        tableView = UITableView(frame: UIScreen.mainScreen().bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.editing = true
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "selection")
        self.view.addSubview(tableView)
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
//        self.definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
//        searchController?.dimsBackgroundDuringPresentation = false
        
    }
}

extension SearchDestinationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedDestinations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("selection", forIndexPath: indexPath)
        if let city = selectedDestinations[indexPath.row].city {
            cell.textLabel?.text = city
        } else if let state = selectedDestinations[indexPath.row].state {
            cell.textLabel?.text = state
        } else if let country = selectedDestinations[indexPath.row].country {
            cell.textLabel?.text = country
        }
        return cell
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
//        
//    }
//    
//    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
//        
//    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Your Selected Destinations"
        default:
            return "Your Selected Destinations"
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            selectedDestinations.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        default:
            break //do nothing
        }
    }
}

// Handle the user's selection.
extension SearchDestinationViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        // Do something with the selected place.
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        
        var selectedPlace = Destination()
        
        for item in place.addressComponents! {
            if item.type == kGMSPlaceTypeLocality || item.type == kGMSPlaceTypeAdministrativeAreaLevel3 || item.type == kGMSPlaceTypeSublocalityLevel3 || item.type == kGMSPlaceTypeColloquialArea { //city
                selectedPlace.city = item.name
            } else if item.type == kGMSPlaceTypeAdministrativeAreaLevel1 { //state
                selectedPlace.state = item.name
            } else if item.type == kGMSPlaceTypeCountry { //country
                selectedPlace.country = item.name
            }
        }
        
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.beginUpdates()
            self.selectedDestinations.append(selectedPlace)
            let indexPath = NSIndexPath(forRow: self.selectedDestinations.endIndex - 1, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            self.tableView.endUpdates()
        }
        
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