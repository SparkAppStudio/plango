//
//  SearchDestinationViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/19/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
//import GoogleMaps
import GooglePlaces

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
    
    lazy var suggestedDestinations: [Destination] = {
        //Populate suggested Popular Destinations
        let sf = Destination(city: "San Francisco", state: "CA", country: "United States")
        let ny = Destination(city: "New York", state: "NY", country: "United States")
        let hongKong = Destination(city: "Hong Kong", state: nil, country: "Hong Kong")
        let rome = Destination(city: "Rome", state: "Lazio", country: "Italy")
        let paris = Destination(city: "Paris", state: "Ile-de-France", country: "France")
        let london = Destination(city: "London", state: "England", country: "United Kingdom")
        let carmen = Destination(city: "Playa del Carmen", state: "Quintana Roo", country: "Mexico")
        let hawaii = Destination(city: nil, state: "HI", country: "United States")
        let newZealand = Destination(city: nil, state: nil, country: "New Zealand")
        let costaRica = Destination(city: nil, state: nil, country: "Costa Rica")
        

        let destinations = [costaRica, newZealand, hawaii, carmen, london, paris, rome, hongKong, sf, ny]
        return destinations
    }()
    
    func didTapSearch(sender: UIButton) {
        if let parent = parentViewController as? SearchViewController {
            parent.collectSearchParameters()
            let parameters = Plango.sharedInstance.buildParameters(parent.minDuration, maxDuration: parent.maxDuration, tags: parent.selectedTags, selectedDestinations: parent.selectedDestinations, user: nil, isJapanSearch: nil)
            
            let plansVC = PlansTableViewController()
            plansVC.plansEndPoint = Plango.EndPoint.FindPlans.rawValue
            plansVC.findPlansParameters = parameters
            plansVC.navigationItem.title = "RESULTS"
            plansVC.hidesBottomBarWhenPushed = true
            self.showViewController(plansVC, sender: nil)

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: UIScreen.mainScreen().bounds)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 227, 0) //status+nav+pager+tab + Search Button, not sure why i need it here but not on itineraryTVC

        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = UIColor.plangoBackgroundGray()
        tableView.backgroundView = UIView() //to fix and allow background gray show through search headerview

        tableView.delegate = self
        tableView.dataSource = self
//        tableView.editing = true
//        tableView.allowsSelectionDuringEditing = true
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "selection")
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        
        self.view.addSubview(tableView)
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        //style the search bar
        searchController?.searchBar.tintColor = UIColor.plangoOrange()
        searchController?.searchBar.barTintColor = UIColor.plangoBackgroundGray()
        searchController?.searchBar.backgroundImage = UIImage() //removes 1px border at top and bottom

        
        // Put the search bar in the tableview header bar.
        searchController?.searchBar.sizeToFit()

        self.tableView.tableHeaderView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
//        self.definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.dimsBackgroundDuringPresentation = false
        
        
        
        searchButton = UIButton(type: .Custom)

        searchButton.setTitle("Get Plans", forState: .Normal)
        searchButton.backgroundColor = UIColor.plangoOrange()
        searchButton.titleLabel?.textColor = UIColor.whiteColor()
        searchButton.titleLabel?.font = UIFont.plangoButton()
        searchButton.addTarget(self, action: #selector(didTapSearch), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(searchButton)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        searchButton.frame = CGRect(x: 0, y: self.view.frame.height - 60, width: self.view.frame.width, height: 60)
    }
}

extension SearchDestinationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedDestinations.count > 0 {
            return selectedDestinations.count
        } else {
            return suggestedDestinations.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("selection", forIndexPath: indexPath)
        cell.imageView?.image = nil
//        cell.imageView?.hidden = true
        cell.contentView.backgroundColor = UIColor.plangoBackgroundGray()
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textAlignment = .Center
        cell.textLabel?.textColor = UIColor.plangoText()
        cell.textLabel?.font = UIFont.plangoBodyBig()
        
        if selectedDestinations.count > 0 {
            cell.imageView?.image = UIImage(named: "unselect")
            if let city = selectedDestinations[indexPath.row].city {
                cell.textLabel?.text = city
            } else if let state = selectedDestinations[indexPath.row].state {
                //TODO: crashes here on non US states
                if let fullState = state.getLongState() {
                    cell.textLabel?.text = fullState.capitalizedString
                } else {
                    cell.textLabel?.text = state.capitalizedString
                }
            } else if let country = selectedDestinations[indexPath.row].country {
                cell.textLabel?.text = country
            }
        } else {
            if let city = suggestedDestinations[indexPath.row].city {
                cell.textLabel?.text = city
            } else if let state = suggestedDestinations[indexPath.row].state {
                cell.textLabel?.text = state.getLongState()!.capitalizedString
            } else if let country = suggestedDestinations[indexPath.row].country {
                cell.textLabel?.text = country
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedDestinations.count == 0 {
            selectedDestinations.append(suggestedDestinations[indexPath.row])
            let section = NSIndexSet(index: indexPath.section)
            tableView.reloadSections(section, withRowAnimation: .Automatic)
        } else {
            deleteAtIndexPath(indexPath)
        }
    }
    
    func deleteAtIndexPath(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        selectedDestinations.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        if selectedDestinations.count == 0 {
            let section = NSIndexSet(index: indexPath.section)
            tableView.reloadSections(section, withRowAnimation: .Automatic)
        }
        
        tableView.endUpdates()
    }
//
//    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
//        
//    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header")
        headerView!.contentView.backgroundColor = UIColor.plangoBackgroundGray()
        
        if selectedDestinations.count > 0 {
            headerView!.textLabel!.text = "You've Selected"
        } else {
            headerView!.textLabel!.text = "Popular Destinations"
        }
        
        return headerView
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textAlignment = .Center
        headerView.textLabel!.textColor = UIColor.plangoTextLight()
        headerView.textLabel!.font = UIFont.plangoSearchHeader()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Helper.HeaderHeight.section.value
    }
    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        if selectedDestinations.count > 0 {
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
//        return .Delete
//    }
//    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        switch editingStyle {
//        case .Delete:
//            tableView.beginUpdates()
//            selectedDestinations.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//            if selectedDestinations.count == 0 {
//                let section = NSIndexSet(index: indexPath.section)
//                tableView.reloadSections(section, withRowAnimation: .Automatic)
//            }
//
//            tableView.endUpdates()
//        default:
//            break //do nothing
//        }
//    }
}

// Handle the user's selection.
extension SearchDestinationViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        // Do something with the selected place.
//        print("Place name: ", place.name)
//        print("Place address: ", place.formattedAddress)
//        print("Place attributions: ", place.attributions)
        
        var selectedPlace = Destination()
        
        for item in place.addressComponents! {
                        
            //redudant because different countries do these things differently, so far I've only seen locality or colloquialArea used but i havd admin3 and sublocal3 code ready just in case. Be careful with admin3 though because it is "townships" in American cities and can throw off the data
            
            if item.type == kGMSPlaceTypeAdministrativeAreaLevel3 { //township
                print("Admin3: \(item.name)")
                
            } else if item.type == kGMSPlaceTypeSublocalityLevel3 {
                print("Sublocality3: \(item.name)")
                
            } else if item.type == kGMSPlaceTypeColloquialArea { //nickname
                print("ColloquialArea: \(item.name)")
                selectedPlace.city = item.name
            } else if item.type == kGMSPlaceTypeLocality { //city
                print("Locality: \(item.name)")
                selectedPlace.city = item.name
            } else if item.type == kGMSPlaceTypeAdministrativeAreaLevel1 { //state
                print("Admin1: \(item.name)")
                selectedPlace.state = item.name
            } else if item.type == kGMSPlaceTypeCountry { //country
                print("Country: \(item.name)")
                selectedPlace.country = item.name
            }
        }
        
        //abbreviate State for specific countries
        //TODO: - add more countries
        if selectedPlace.country == "United States" {
            if let stateLong = selectedPlace.state {
                selectedPlace.state = stateLong.getShortState()?.rawValue
            }
            
        } else if selectedPlace.country == "Australia" {
            if let stateLong = selectedPlace.state {
                selectedPlace.state = stateLong.getShortStateAustralia()?.rawValue
            }
            
        } else if selectedPlace.country == "Canada" {
            if let stateLong = selectedPlace.state {
                selectedPlace.state = stateLong.getShortStateCanada()?.rawValue
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.beginUpdates()
            self.selectedDestinations.append(selectedPlace)
            let indexPath = NSIndexPath(forRow: self.selectedDestinations.endIndex - 1, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            if self.selectedDestinations.count == 1 {
                let section = NSIndexSet(index: indexPath.section)
                self.tableView.reloadSections(section, withRowAnimation: .Automatic)
            }
            
            self.tableView.endUpdates()
        }
        
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: NSError){
        // TODO: handle the error.
        self.printError(error)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
