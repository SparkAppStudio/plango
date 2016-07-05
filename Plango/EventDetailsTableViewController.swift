//
//  EventTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

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
    
    var event: Event!
    var experience: Experience!
    var headerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()
        self.navigationItem.title = experience.name
        
        let reviewNib = UINib(nibName: "ReviewCell", bundle: nil)
        self.tableView.registerNib(reviewNib, forCellReuseIdentifier: CellID.Review.rawValue)
        
        let notesNib = UINib(nibName: "NotesCell", bundle: nil)
        self.tableView.registerNib(notesNib, forCellReuseIdentifier: CellID.Notes.rawValue)

        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "EventDetailsHeader", bundle: bundle)
        headerView = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 180))
        
        containerView.addSubview(headerView)
        tableView.tableHeaderView = containerView


    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.text = experience.name
        addressLabel.text = experience.address
        reviewLabel.text = experience.rating
        
        guard let endPoint = experience.avatar else {
            coverImageView.backgroundColor = UIColor.plangoBrown()
            return
        }
        coverImageView.af_setImageWithURL(NSURL(string: endPoint)!)
    }
    
    // MARK: - Table view Delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case EventTitles.MyNotes.section:
            return Helper.CellHeight.superWide.value
        case EventTitles.Tips.section:
            return Helper.CellHeight.reviews.value
        default:
            return Helper.CellHeight.reviews.value
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case EventTitles.MyNotes.section:
            return "My Notes"
        case EventTitles.Tips.section:
            return "Tips and Reviews"
        default:
            return nil
        }
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
            let cell = tableView.dequeueReusableCellWithIdentifier(CellID.Notes.rawValue, forIndexPath: indexPath) as! NotesTableViewCell
            
            cell.experience = experience
            cell.configure()
            
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
