//
//  ItineraryTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import MapKit

class ItineraryTableViewController: UITableViewController, EventTableViewCellDelegate {
    
    var events: [Event]!
    var experiences: [Experience]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()
        let cellNib = UINib(nibName: "EventCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: CellID.Event.rawValue)


    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.clipsToBounds = true
    }


    func displayMapForExperience(experience: Experience) {
        
        guard let latitute: CLLocationDegrees = experience.geocode?.first else {return}
        guard let longitute: CLLocationDegrees = experience.geocode?.last else {return}
                
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(experience.name)"
        mapItem.openInMapsWithLaunchOptions(options)
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
        cell.delegate = self
        cell.configure()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! EventTableViewCell
        let eventDetails = EventDetailsTableViewController()
        eventDetails.event = cell.event
        eventDetails.experience = cell.experience
        
        showViewController(eventDetails, sender: nil)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if experiences[indexPath.row].avatar != nil {
            return 180
        } else {
            return 80
        }
    }
}
