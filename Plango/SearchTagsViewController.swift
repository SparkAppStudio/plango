//
//  SearchTagsViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/24/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class TagsResultsViewController: UITableViewController {
    var filteredTags = [Tag]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tag")
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTags.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tag", forIndexPath: indexPath)
        
        let tag = filteredTags[indexPath.row]
        cell.textLabel!.text = tag.name
        return cell
    }
}

class SearchTagsViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {

    lazy var tags = [Tag]()
    var searchController: UISearchController?

    lazy var resultsViewController: TagsResultsViewController = {
       let controller = TagsResultsViewController()
        return controller
    }()

    var tableView: UITableView!
    lazy var suggestions = [String](["Adventerous", "Foodie"])

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: UIScreen.mainScreen().bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "suggestion")
        self.view.addSubview(tableView)
        
        Plango.sharedInstance.fetchTags(Plango.EndPoint.AllTags.rawValue) { (receivedTags, errorString) in
            if let error = errorString {
                print(error)
            } else if let tags = receivedTags {
                self.tags = tags
                self.tableView.reloadData()
            }
        }
        
        resultsViewController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
        searchController?.searchBar.delegate = self
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
//        searchController?.dimsBackgroundDuringPresentation = false

    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        resultsViewController.tableView.reloadData()
    }
    
    func filterContentForSearchText(searchText: String) {
        resultsViewController.filteredTags = self.tags.filter { (tag) -> Bool in
            return tag.name!.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
    
}

extension SearchTagsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let suggestions = self.suggestions {
            return suggestions.count
//        } else {
//            return 0
//        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("suggestion", forIndexPath: indexPath)
        cell.textLabel?.text = suggestions[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .Checkmark
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
        
    }
}
