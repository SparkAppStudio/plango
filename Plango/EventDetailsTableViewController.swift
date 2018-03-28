//
//  EventTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit


class EventDetailsTableViewController: UITableViewController {
    
    @IBOutlet weak var coverImageView: CompoundImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    
    enum EventTitles: String { //use when experience has notes, otherwise see ifstatements
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
    
    @objc func didTapDirections() {
        displayMapForExperiences([experience], title: experience.name, download: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if experience.geocode?.count == 2 {
            let directionsBarButton = UIBarButtonItem(image: UIImage(named: "directions-white"), style: .plain, target: self, action: #selector(didTapDirections))
            self.navigationItem.rightBarButtonItem = directionsBarButton
        }


        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()
        self.navigationItem.title = experience.name?.uppercased()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        let reviewNib = UINib(nibName: "ReviewCell", bundle: nil)
        self.tableView.register(reviewNib, forCellReuseIdentifier: CellID.Review.rawValue)
        
//        self.tableView.registerNib(notesNib, forCellReuseIdentifier: CellID.Notes.rawValue)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellID.Notes.rawValue)
        
        let bundle = Bundle(for: type(of: self))
        
        // headerfooter view is like a cell
        let sectionNib = UINib(nibName: "SectionHeader", bundle: nil)
        self.tableView.register(sectionNib, forHeaderFooterViewReuseIdentifier: CellID.Header.rawValue)
        
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: CellID.Footer.rawValue)

        //tableHeader view
        
        let nib = UINib(nibName: "EventDetailsHeader", bundle: bundle)
        headerView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        headerView.snp.makeConstraints { (make) in
            make.height.equalTo(Helper.CellHeight.superWide.value)
        }
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: Helper.CellHeight.superWide.value))
        
        containerView.addSubview(headerView)
        
        tableView.tableHeaderView = containerView
        
        headerView.leadingAnchor.constraint(equalTo: tableView.tableHeaderView!.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: tableView.tableHeaderView!.trailingAnchor).isActive = true
        headerView.bottomAnchor.constraint(equalTo: tableView.tableHeaderView!.bottomAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: tableView.tableHeaderView!.topAnchor).isActive = true


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.text = experience.name
        addressLabel.text = experience.address
        reviewLabel.text = experience.rating

        coverImageView.plangoImage(experience)
    }
        
    // MARK: - Table view Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard (experience.notes != nil && experience.notes != "") else {return Helper.CellHeight.reviews.value}
        
        switch indexPath.section {
        case EventTitles.MyNotes.section:
            return UITableViewAutomaticDimension
        case EventTitles.Tips.section:
            return Helper.CellHeight.reviews.value
        default:
            return Helper.CellHeight.reviews.value
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Helper.HeaderHeight.section.value
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellID.Header.rawValue) as! SectionHeaderView
        
        guard (experience.notes != nil && experience.notes != "") else {headerView.titleLabel.text = "Tips and Reviews"; return headerView}

        
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
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellID.Footer.rawValue)
        footerView?.isHidden = true //this makes it a transparent footer effect = so you still have gaps but it doesnt hug bottom of screen while scrolling
        return footerView
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard (experience.notes != nil && experience.notes != "") else {return EventTitles.count - 1}

        return EventTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard (experience.notes != nil && experience.notes != "") else {
            if let reviews = experience.reviews {
                return reviews.count
            } else {
                return 0
            }
        }

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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard (experience.notes != nil && experience.notes != "") else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellID.Review.rawValue, for: indexPath) as! ReviewTableViewCell
            
            cell.review = experience.reviews![indexPath.row]
            cell.configure()
            
            return cell
        }

        
        switch indexPath.section {
        case EventTitles.MyNotes.section:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellID.Notes.rawValue, for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.font = UIFont.plangoBody()
            cell.textLabel?.textColor = UIColor.plangoText()
            cell.textLabel?.text = experience.notes
            return cell
            
        case EventTitles.Tips.section:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellID.Review.rawValue, for: indexPath) as! ReviewTableViewCell
            
            cell.review = experience.reviews![indexPath.row]
            cell.configure()
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            
            
            return cell
        }
    }
}
