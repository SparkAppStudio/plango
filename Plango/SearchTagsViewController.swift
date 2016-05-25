//
//  SearchTagsViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/24/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

protocol TagsResultsDelegate: class {
    func didSelectTag(tag: Tag)
}

class TagsResultsViewController: UITableViewController {
    weak var delegate: TagsResultsDelegate?

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
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectTag(filteredTags[indexPath.row])
    }
}

class SearchTagsViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate, TagsResultsDelegate {

    lazy var tags = [Tag]()
    var selectedTags = [Tag]() {
        didSet {
//            if let parent = parentViewController as? SearchViewController {
//                parent.displaySelections(selectedTags, destinations: nil, duration: nil)
//            }
//            self.tableView.reloadData()
        }
    }
    var searchController: UISearchController?

    lazy var resultsViewController: TagsResultsViewController = {
       let controller = TagsResultsViewController()
        controller.delegate = self
        return controller
    }()

    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: UIScreen.mainScreen().bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.editing = true
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "selection")
        self.view.addSubview(tableView)
        
        Plango.sharedInstance.fetchTags(Plango.EndPoint.AllTags.rawValue) { (receivedTags, errorString) in
            if let error = errorString {
                print(error)
            } else if let tags = receivedTags {
                self.tags = tags
                self.tableView.reloadData()
            }
        }
        
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
    
    func didSelectTag(tag: Tag) {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.beginUpdates()
            self.selectedTags.append(tag)
            let indexPath = NSIndexPath(forRow: self.selectedTags.endIndex - 1, inSection: 0)
            
            self.searchController?.searchBar.text = nil
            self.searchController!.searchResultsController?.dismissViewControllerAnimated(true, completion: nil)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            self.tableView.endUpdates()
        }
    }
}

extension SearchTagsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("selection", forIndexPath: indexPath)
        cell.textLabel?.text = selectedTags[indexPath.row].name
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
            return "Your Selected Tags"
        default:
            return "Your Selected Tags"
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
            selectedTags.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        default:
            break //do nothing
        }
    }
}
