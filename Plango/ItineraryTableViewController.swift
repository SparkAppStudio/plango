//
//  ItineraryTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class ItineraryTableViewController: UITableViewController {
    
    var events: [Event]!
    var experiences: [Experience]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.plangoCream()
        let cellNib = UINib(nibName: "EventCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: CellID.Event.rawValue)


    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.clipsToBounds = true
    }



    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellID.Event.rawValue, forIndexPath: indexPath) as! EventTableViewCell
        
        cell.event = events[indexPath.row]
        cell.experience = experiences[indexPath.row]
        
        cell.configure()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if experiences[indexPath.row].avatar != nil {
            return 180
        } else {
            return 80
        }
    }
}
