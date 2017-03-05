//
//  ItineraryTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class ItineraryTableViewController: UITableViewController, EventTableViewCellDelegate {
    
    var events: [Event]!
    var experiences: [Experience]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none

        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()
        let cellNib = UINib(nibName: "EventCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: CellID.Event.rawValue)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.clipsToBounds = true
    }
    
    func didSendExperience(_ experience: Experience) {
        displayMapForExperiences([experience], title: experience.name, download: false)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID.Event.rawValue, for: indexPath) as! EventTableViewCell
        
        cell.event = events[indexPath.row]
        cell.experience = experiences[indexPath.row]
        cell.delegate = self
        cell.configure()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! EventTableViewCell
        let eventDetails = EventDetailsTableViewController()
//        eventDetails.event = cell.event
        eventDetails.experience = cell.experience
        
        show(eventDetails, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if experiences[indexPath.row].avatar != nil {
            return 160
        } else {
            return Helper.CellHeight.reviews.value
        }
    }
}
