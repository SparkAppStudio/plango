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
        tableView.backgroundColor = UIColor.plangoBackgroundGray()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tag")
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTags.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tag", forIndexPath: indexPath)
        
        cell.contentView.backgroundColor = UIColor.plangoBackgroundGray()
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textAlignment = .Left
        cell.textLabel?.textColor = UIColor.plangoText()
        cell.textLabel?.font = UIFont.plangoBodyBig()

        
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
    
//    var selectedIndexPath: NSIndexPath!
//    lazy var deleteButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = UIColor.plangoBackgroundGray()
//        button.tintColor = UIColor.plangoOrange()
//        button.setImage(UIImage(named: "directions"), forState: .Normal)
//        
//        button.addTarget(self, action: #selector(didTapDelete), forControlEvents: .TouchUpInside)
//        return button
//    }()
//    lazy var accessoryView: UIView = {
//       let view = UIView(frame: CGRectMake(0, 0, 60, 60))
//        view.backgroundColor = UIColor.plangoBackgroundGray()
//        return view
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: UIScreen.mainScreen().bounds)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 227, 0) //status+nav+pager+tab+SearchButton, not sure why i need it here but not on itineraryTVC

        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = UIColor.plangoBackgroundGray()
        tableView.backgroundView = UIView() //to fix and allow background gray show through search headerview

        tableView.delegate = self
        tableView.dataSource = self
//        tableView.editing = true
//        tableView.allowsSelectionDuringEditing = true

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "selection")
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")

        self.view.addSubview(tableView)
        
        Plango.sharedInstance.fetchTags(Plango.EndPoint.AllTags.rawValue) { (receivedTags, error) in
            if let error = error {
                self.printPlangoError(error)
            } else if let tags = receivedTags {
                self.tags = tags
                self.tableView.reloadData()
            }
        }
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
        searchController?.searchBar.delegate = self
        
        // style the search bar
        searchController?.searchBar.tintColor = UIColor.plangoOrange()
        searchController?.searchBar.barTintColor = UIColor.plangoBackgroundGray()
        searchController?.searchBar.backgroundImage = UIImage() //removes 1px border at top and bottom
        
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
        
        self.tableView.clipsToBounds = true
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
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            if self.selectedTags.count == 1 {
                let section = NSIndexSet(index: indexPath.section)
                self.tableView.reloadSections(section, withRowAnimation: .Automatic)
            }
            
            self.tableView.endUpdates()
        }
    }
}

extension SearchTagsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedTags.count > 0 {
            return selectedTags.count
        } else {
            return tags.count
        }
    }
    
    func deleteAtIndexPath(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        selectedTags.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        if selectedTags.count == 0 {
            let section = NSIndexSet(index: indexPath.section)
            tableView.reloadSections(section, withRowAnimation: .Automatic)
        }
        
        tableView.endUpdates()
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
        
        if selectedTags.count > 0 {
            cell.imageView?.image = UIImage(named: "unselect")
            cell.textLabel?.text = selectedTags[indexPath.row].name
        } else {
            cell.textLabel?.text = tags[indexPath.row].name
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedTags.count == 0 {
            selectedTags.append(tags[indexPath.row])
            let section = NSIndexSet(index: indexPath.section)
            tableView.reloadSections(section, withRowAnimation: .Automatic)
        } else {
            deleteAtIndexPath(indexPath)
        }
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header")
        headerView!.contentView.backgroundColor = UIColor.plangoBackgroundGray()
        
        if selectedTags.count > 0 {
            headerView!.textLabel!.text = "You've Selected"
        } else {
            headerView!.textLabel!.text = "Popular Tags"
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
    
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        let delete = UITableViewRowAction(style: .Destructive, title: "Remove") { action, index in
//        
//        }
//        return [delete]
//    }
    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        if selectedTags.count > 0 {
//            return true
//        } else {
//            return false
//        }
//    }
    
//    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
//        return .Delete
//    }
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        switch editingStyle {
//        case .Delete:
//            tableView.beginUpdates()
//            selectedTags.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//            if selectedTags.count == 0 {
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
