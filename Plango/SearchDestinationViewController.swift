//
//  Search2ViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/19/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import GoogleMaps

class SearchDestinationViewController: UIViewController {
    
    var searchController: UISearchController?
    
    var suggestions: [Destination]?
    
    var tableView: UITableView!
    
    lazy var resultsViewController: GMSAutocompleteResultsViewController = {
       let resultsVC  = GMSAutocompleteResultsViewController()
        resultsVC.delegate = self
        return resultsVC
    }()
    
    var selectedDestinations = [Destination]() {
        didSet {
            if let parent = parentViewController as? SearchViewController {
                parent.displaySelections(nil, destinations: selectedDestinations, duration: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sydney = Destination(city: "Sydney", state: "NSW", country: "Australia")
        let newYork = Destination(city: "New York", state: "NY", country: "United States")
        
        
        suggestions = [sydney, newYork]
        
        tableView = UITableView(frame: UIScreen.mainScreen().bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "suggestion")
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
//        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.dimsBackgroundDuringPresentation = false
        
    }
}

extension SearchDestinationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let suggestions = self.suggestions {
            return suggestions.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("suggestion", forIndexPath: indexPath)
        cell.textLabel?.text = suggestions![indexPath.row].city
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
        
        selectedDestinations.append(selectedPlace)
        
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
