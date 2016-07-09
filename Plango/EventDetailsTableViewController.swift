//
//  EventTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import MapKit

class EventDetailsTableViewController: UITableViewController {
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    
    enum EventTitles: String {
        case MyNotes = "My Notes"
        case Tips = "Tips and Reviews"
        
        var section: Int {
            switch self {
            case .MyNotes: return 0
            case .Tips: return 1
            }
        }
        
        static var count: Int {
            //whatever the last case in the enum is, then plus 1 gives you the count
            return EventTitles.Tips.hashValue + 1
        }
    }
    
//    var event: Event!
    var experience: Experience!
    var headerView: UIView!
    
    func didTapDirections() {
        displayMapForExperience(experience)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let directionsBarButton = UIBarButtonItem(image: UIImage(named: "directions-white"), style: .Plain, target: self, action: #selector(didTapDirections))
        self.navigationItem.rightBarButtonItem = directionsBarButton

        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()
        self.navigationItem.title = experience.name
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        let reviewNib = UINib(nibName: "ReviewCell", bundle: nil)
        self.tableView.registerNib(reviewNib, forCellReuseIdentifier: CellID.Review.rawValue)
        
//        self.tableView.registerNib(notesNib, forCellReuseIdentifier: CellID.Notes.rawValue)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CellID.Notes.rawValue)
        
        let bundle = NSBundle(forClass: self.dynamicType)
        
        // headerfooter view is like a cell
        let sectionNib = UINib(nibName: "SectionHeader", bundle: nil)
        self.tableView.registerNib(sectionNib, forHeaderFooterViewReuseIdentifier: CellID.Header.rawValue)
        
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: CellID.Footer.rawValue)

        //tableHeader view
        
        let nib = UINib(nibName: "EventDetailsHeader", bundle: bundle)
        headerView = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        headerView.snp_makeConstraints { (make) in
            make.height.equalTo(Helper.CellHeight.superWide.value)
        }
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: Helper.CellHeight.superWide.value))
        
        containerView.addSubview(headerView)
        
        tableView.tableHeaderView = containerView
        
        headerView.leadingAnchor.constraintEqualToAnchor(tableView.tableHeaderView!.leadingAnchor).active = true
        headerView.trailingAnchor.constraintEqualToAnchor(tableView.tableHeaderView!.trailingAnchor).active = true
        headerView.bottomAnchor.constraintEqualToAnchor(tableView.tableHeaderView!.bottomAnchor).active = true
        headerView.topAnchor.constraintEqualToAnchor(tableView.tableHeaderView!.topAnchor).active = true


    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.text = experience.name
        addressLabel.text = experience.address
        reviewLabel.text = experience.rating
        
        guard let endPoint = experience.avatar else {
            coverImageView.backgroundColor = UIColor.plangoText()
            return
        }
        coverImageView.af_setImageWithURL(NSURL(string: endPoint)!)
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
        if let name = experience.name {
            mapItem.name = name
        }
        mapItem.openInMapsWithLaunchOptions(options)
    }
    
    // MARK: - Table view Delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case EventTitles.MyNotes.section:
            return UITableViewAutomaticDimension
        case EventTitles.Tips.section:
            return Helper.CellHeight.reviews.value
        default:
            return Helper.CellHeight.reviews.value
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(CellID.Header.rawValue) as! SectionHeaderView
        
        switch section {
        case EventTitles.MyNotes.section:
            headerView.titleLabel.text = "My Notes"
        case EventTitles.Tips.section:
            headerView.titleLabel.text = "Tips and Reviews"
        default:
            headerView.titleLabel.text = ""
        }
        
        return headerView
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(CellID.Footer.rawValue)
        footerView?.contentView.backgroundColor = UIColor.plangoBackgroundGray()
        return footerView
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return EventTitles.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case EventTitles.MyNotes.section:
            return 1
        case EventTitles.Tips.section:
            if let reviews = experience.reviews {
                return reviews.count
            } else {
            return 0
            }
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case EventTitles.MyNotes.section:
            let cell = tableView.dequeueReusableCellWithIdentifier(CellID.Notes.rawValue, forIndexPath: indexPath)
            cell.selectionStyle = .None
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .ByWordWrapping
            cell.textLabel?.font = UIFont.plangoBody()
            cell.textLabel?.textColor = UIColor.plangoText()
            cell.textLabel?.text = experience.notes
            return cell
            
        case EventTitles.Tips.section:
            let cell = tableView.dequeueReusableCellWithIdentifier(CellID.Review.rawValue, forIndexPath: indexPath) as! ReviewTableViewCell
            
            cell.review = experience.reviews![indexPath.row]
            cell.configure()
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
            
            
            return cell
        }
    }
}
