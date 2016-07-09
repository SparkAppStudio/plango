//
//  PlanSummaryViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import SnapKit
import AlamofireImage
import CZWeatherKit

class PlanSummaryViewController: UITableViewController {
    
    private enum SummaryTitles: String {
        case Start = ""
        case Overview = "Overview"

        var section: Int {
            switch self {
            case .Start: return 0
            case .Overview: return 1
            }
        }
        
        static var count: Int {
            //whatever the last case in the enum is, then plus 1 gives you the count
            return SummaryTitles.Overview.hashValue + 1
        }
    }

    // SummaryHeader xib
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var climaconLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    // SummaryStart xib
    @IBOutlet weak var startDaysLabel: UILabel!
    @IBOutlet weak var startHoursLabel: UILabel!
    @IBOutlet weak var startMinutesLabel: UILabel!
    @IBOutlet weak var startSecondsLabel: UILabel!
    
    //DownloadView xib
    @IBAction func didTapDownload(sender: UIButton) {
        //TODO: - download info to device
    }
    
    
    var headerView: UIView!
    var startView: UIView!
    var detailsView: UIView!
    var downloadView: UIView!
    
    var stackView: UIStackView!
    var buttonStackView: UIStackView!
    
    var plan: Plan!
    var myPlan: Bool! = false
    
    var experiencesByPlace: [String:[Experience]]!
    
    let calendar = NSCalendar.currentCalendar()
    var days = 0
    var hours = 0
    var minutes = 0
    var seconds = 0
    
//    lazy var downloadButton: UIButton = {
//        let button = UIButton()
//
//        button.backgroundColor = UIColor.plangoOrange()
//        button.tintColor = UIColor.whiteColor()
//        button.setTitle("Go Offline!", forState: UIControlState.Normal)
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
//        button.setImage(UIImage(named: "download"), forState: .Normal)
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
//        button.titleLabel?.font = UIFont.plangoButton()
//
//        button.addTarget(self, action: #selector(didTapDownload), forControlEvents: .TouchUpInside)
//        return button
//    }()
    
    lazy var itineraryButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = UIColor.whiteColor()
        button.layer.borderColor = UIColor.plangoBackgroundGray().CGColor
        button.layer.borderWidth = 1
        button.tintColor = UIColor.plangoTeal()
        button.setTitleColor(UIColor.plangoTeal(), forState: .Normal)
        button.titleLabel?.font = UIFont.plangoSmallButton()
        button.setTitle("Itinerary", forState: .Normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        button.setImage(UIImage(named: "itinerary-teal"), forState: .Normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(didTapItinerary), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var mapButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.whiteColor()
        button.layer.borderColor = UIColor.plangoBackgroundGray().CGColor
        button.layer.borderWidth = 1

        button.tintColor = UIColor.plangoTeal()
        button.setTitleColor(UIColor.plangoTeal(), forState: .Normal)
        button.titleLabel?.font = UIFont.plangoSmallButton()
        button.setTitle("Map", forState: .Normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        button.setImage(UIImage(named: "map-teal"), forState: .Normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(didTapMap), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var friendsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.whiteColor()
        button.layer.borderColor = UIColor.plangoBackgroundGray().CGColor
        button.layer.borderWidth = 1

        button.tintColor = UIColor.plangoTeal()
        button.setTitleColor(UIColor.plangoTeal(), forState: .Normal)
        button.titleLabel?.font = UIFont.plangoSmallButton()
        button.setTitle("Friends", forState: .Normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        button.setImage(UIImage(named: "friends-teal"), forState: .Normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(didTapFriends), forControlEvents: .TouchUpInside)
        return button
    }()
    
    func weather() {
        
        let date = NSDate()
        let coordinate = CLLocationCoordinate2DMake(37.7749, -122.4194)
//        let coordinate = CLLocationCoordinate2DMake(-33.867487, 151.206990)

        let rounder = NSDecimalNumberHandler(roundingMode: .RoundBankers, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)

        
        let request = CZForecastioRequest.newForecastRequestWithDate(date)
        request.key = "9c74ebb83e3387c347b8eb741b6402d5"
//        request.location = CZWeatherLocation(fromCity: "Sydney", country: "Australia")
//        request.location = CZWeatherLocation(fromCity: "Los Angeles", state: "CA")
        request.location = CZWeatherLocation(fromCoordinate: coordinate)
        request.sendWithCompletion { (data, error) -> Void in
            if let error = error {
                self.printError(error)
            } else if let weather = data {
                let forecast = weather.dailyForecasts.first as! CZWeatherForecastCondition
                dispatch_async(dispatch_get_main_queue(), { () -> Void in

                    print("high: \(forecast.highTemperature.f) low: \(forecast.lowTemperature.f)")
                    let avgTempFloat = (forecast.highTemperature.f + forecast.lowTemperature.f) / 2
                    let avgTemp = NSDecimalNumber(float: avgTempFloat).decimalNumberByRoundingAccordingToBehavior(rounder)
                    
                    self.temperatureLabel.text = String(avgTemp)
                    self.weatherLabel.text = forecast.summary
                    let climaChar = forecast.climacon.rawValue
                    let climaString = NSString(format: "%c", climaChar)
                    self.climaconLabel.text = String(climaString)
                })
            }
        }
    }
    
    func getOverviewStrings() {
        if let startDate = plan.startDate, endDate = plan.endDate {
            let formatter = NSDateFormatter()
            formatter.timeZone = NSTimeZone.defaultTimeZone()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            let startDateString = formatter.stringFromDate(startDate)
            let endDateString = formatter.stringFromDate(endDate)
            
            if myPlan == true {
                overviewTextArray.append("\(startDateString)        to        \(endDateString)")
            }
        }

        if let planDescription = plan.planDescription {
            overviewTextArray.append(planDescription)
        }

        if let tags = plan.tags {
            overviewTextArray.append(parseTags(tags, comma: false))
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = UIColor.plangoBackgroundGray()
        
        if let plan = self.plan {
            if let user = Plango.sharedInstance.currentUser {
                if plan.authorID == user.id {
                    myPlan = true
                } else {
                    myPlan = false
                }
            }
            
            experiencesByPlace = parseExperiencesIntoPlaces(plan.experiences, places: plan.places)
            
            getOverviewStrings()
            
        }
        
        let _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: true)
        
        let bundle = NSBundle(forClass: self.dynamicType)
        
        let nibHeader = UINib(nibName: "SummaryHeader", bundle: bundle)
        headerView = nibHeader.instantiateWithOwner(self, options: nil)[0] as! UIView
        headerView.snp_makeConstraints { (make) in
            make.height.equalTo(Helper.CellHeight.superWide.value)
        }
        
        let nibStart = UINib(nibName: "SummaryStart", bundle: bundle)
        startView = nibStart.instantiateWithOwner(self, options: nil)[0] as! UIView
        startView.snp_makeConstraints { (make) in
            make.height.equalTo(200)
        }
        
        let nibDownload = UINib(nibName: "DownloadView", bundle: bundle)
        downloadView = nibDownload.instantiateWithOwner(self, options: nil)[0] as! UIView
        downloadView.snp_makeConstraints { (make) in
            make.height.equalTo(160)
        }
        
        // headerfooter view is like a cell
        let sectionNib = UINib(nibName: "SectionHeader", bundle: nil)
        self.tableView.registerNib(sectionNib, forHeaderFooterViewReuseIdentifier: CellID.Header.rawValue)
        
        tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: CellID.Footer.rawValue)
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Start")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Overview")
        
        let experienceNib = UINib(nibName: "ExperienceCell", bundle: nil)
        tableView.registerNib(experienceNib, forCellReuseIdentifier: CellID.Experience.rawValue)

        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: Helper.CellHeight.superWide.value))
        
        containerView.addSubview(headerView)
        
        headerView.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor).active = true
        headerView.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor).active = true
        headerView.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor).active = true
        headerView.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        
        tableView.tableHeaderView = containerView


//        scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.backgroundColor = UIColor.plangoBackgroundGray()
//        view.addSubview(scrollView)
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .Vertical
        stackView.spacing = 12
//        scrollView.addSubview(stackView)
        
        
//        scrollView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
//        scrollView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
//        scrollView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
//        scrollView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
//        scrollView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        
        buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .Horizontal
        buttonStackView.distribution = .FillEqually
//        buttonStackView.spacing = 4
        buttonStackView.snp_makeConstraints { (make) in
            make.height.equalTo(50)
        }
        
        buttonStackView.addArrangedSubview(itineraryButton)
        buttonStackView.addArrangedSubview(mapButton)
        if myPlan == true {
            buttonStackView.addArrangedSubview(friendsButton)
        }
        
        stackView.addArrangedSubview(buttonStackView)
        
        if myPlan == true {
            stackView.addArrangedSubview(startView)
            stackView.addArrangedSubview(downloadView)
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let places = plan.places else {return SummaryTitles.count}
        return SummaryTitles.count + places.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SummaryTitles.Start.section:
            return 1
        case SummaryTitles.Overview.section:
            return overviewTextArray.count
        default:
            guard let places = plan.places else {return 0}
            let placeID = places[section - 2].id //subtract 2 because of 1st 2 hard coded sections
            guard let experiences = experiencesByPlace[placeID] else {return 0}
            return experiences.count
            
            //            if experiences.count < 3 {
            //                return experiences.count
            //            } else {
            //                return 3
            //            }
        }
    }
    
    var overviewTextArray = [String]()
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SummaryTitles.Start.section:
            let cell = tableView.dequeueReusableCellWithIdentifier("Start", forIndexPath: indexPath)
            cell.selectionStyle = .None
            cell.contentView.backgroundColor = UIColor.plangoBackgroundGray()
            cell.contentView.addSubview(stackView)
            
            stackView.leadingAnchor.constraintEqualToAnchor(cell.contentView.leadingAnchor).active = true
            stackView.trailingAnchor.constraintEqualToAnchor(cell.contentView.trailingAnchor).active = true
            stackView.bottomAnchor.constraintEqualToAnchor(cell.contentView.bottomAnchor).active = true
            stackView.topAnchor.constraintEqualToAnchor(cell.contentView.topAnchor).active = true
            stackView.widthAnchor.constraintEqualToAnchor(cell.contentView.widthAnchor).active = true

            return cell
        case SummaryTitles.Overview.section:
            let cell = tableView.dequeueReusableCellWithIdentifier("Overview", forIndexPath: indexPath)
            cell.selectionStyle = .None
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .ByWordWrapping
            cell.textLabel?.font = UIFont.plangoBodyBig()
            cell.textLabel?.textColor = UIColor.plangoText()
            cell.textLabel!.text = overviewTextArray[indexPath.row]

            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(CellID.Experience.rawValue, forIndexPath: indexPath) as! ExperienceTableViewCell
            
            guard let places = plan.places else {return cell}
            let placeID = places[indexPath.section - 2].id
            guard let experiences = experiencesByPlace[placeID] else {return cell}
            
            cell.experience = experiences[indexPath.row]
            cell.configure()
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case SummaryTitles.Start.section:
            if myPlan == true {
                return 50 + 200 + 160 + 24 //buttonstackview + startview + download + spacing
            } else {
                return 50 //buttonstackview
            }
        case SummaryTitles.Overview.section:
            return UITableViewAutomaticDimension
        default:
            return 80
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(CellID.Footer.rawValue)
        footerView?.contentView.backgroundColor = UIColor.plangoBackgroundGray()
        return footerView
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func parseExperiencesIntoPlaces(experiences: [Experience]?, places: [Place]?) -> [String:[Experience]] {
        var placesExperiences = [String:[Experience]]()
        guard let places = places, experiences = experiences else {return placesExperiences}
        
        for place in places {
            var placeExperiences = [Experience]()
            for experience in experiences {
                if experience.city == place.city {
                    placeExperiences.append(experience)
                }
            }
            placesExperiences[place.id] = placeExperiences
        }
        return placesExperiences
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(CellID.Header.rawValue) as! SectionHeaderView
        
        switch section {
        case SummaryTitles.Start.section:
            return nil
        case SummaryTitles.Overview.section:
            headerView.titleLabel.text = "Overview"
            
            if let cities = plan.places?.count {
                headerView.citiesLabel.hidden = false
                headerView.citiesImageView.hidden = false
                if cities == 1 {
                    headerView.citiesLabel.text = "\(cities) City"
                } else {
                    headerView.citiesLabel.text = "\(cities) Cities"
                }
            }
            
            if let duration = plan.durationDays {
                headerView.daysLabel.hidden = false
                headerView.daysImageView.hidden = false
                if duration == 1 {
                    headerView.daysLabel.text = "\(duration) Day"
                } else {
                    headerView.daysLabel.text = "\(duration) Days"
                }
            }
            
            if let activities = plan.experiences?.count {
                headerView.activitiesLabel.hidden = false
                headerView.activitiesImageView.hidden = false
                if activities == 1 {
                    headerView.activitiesLabel.text = "\(activities) Activity"
                } else {
                    headerView.activitiesLabel.text = "\(activities) Activities"
                }
            }
            return headerView
        default:
            
            guard let places = plan.places else {return nil}
            let place = places[section - 2] //subtract 2 because of 1st 2 hard coded sections
            
            headerView.titleLabel.text = place.city
            
            if let duration = place.durationDays {
                headerView.daysLabel.hidden = false
                headerView.daysImageView.hidden = false

                if duration == 1 {
                    headerView.daysLabel.text = "\(duration) Day"
                } else {
                    headerView.daysLabel.text = "\(duration) Days"
                }
            }
            
            if let activities = experiencesByPlace[place.id]?.count {
                headerView.activitiesLabel.hidden = false
                headerView.activitiesImageView.hidden = false

                if activities == 1 {
                    headerView.activitiesLabel.text = "\(activities) Activity"
                } else {
                    headerView.activitiesLabel.text = "\(activities) Activities"
                }
            }
            
            return headerView
        }

    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case SummaryTitles.Start.section:
            return 0
        case SummaryTitles.Overview.section:
            return 50
        default:
            return 50
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section > 1 {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! ExperienceTableViewCell
            let eventDetails = EventDetailsTableViewController()
            eventDetails.experience = cell.experience
            
            showViewController(eventDetails, sender: nil)

        }
    }
    
    func parseTags(planTags: [String], comma: Bool) -> String {
        
        var tags = ""

        for tagName in planTags {
            if comma == true {
                tags = tags.stringByAppendingString("\(tagName), ")
            } else {
                tags = tags.stringByAppendingString("#\(tagName) ")
            }
        }
        
        if comma == true {
            return String(tags.characters.dropLast(2))
        } else {
            return String(tags.characters.dropLast(1))
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureLabel(startDaysLabel)
        configureLabel(startHoursLabel)
        configureLabel(startMinutesLabel)
        configureLabel(startSecondsLabel)
        
        if let plan = self.plan {
            self.navigationItem.title = plan.name?.uppercaseString
            
            if let endPoint = plan.avatar {
                let cleanURL = NSURL(string: Plango.sharedInstance.cleanEndPoint(endPoint))
                coverImageView.af_setImageWithURL(cleanURL!)
            } else {coverImageView.backgroundColor = UIColor.plangoTeal()}
            
            if let tags = plan.tags {
                tagsLabel.text = parseTags(tags, comma: true)
            }
                        
            guard let days = plan.durationDays else {return}
            
            if days == 1 {
                durationLabel.text = "\(days.description) Day"
            } else {
                durationLabel.text = "\(days.description) Days"
            }
            
            //TODO: - Add this to xib

//            guard let views = plan.viewCount else {return}
//            guard let used = plan.usedCount else {return}

//            viewsCountLabel.text = "\(views) Inspired"
//            usedCountLabel.text = "\(used) Used"
            
            guard let startDate = plan.startDate else {return}
            
            startTimer(startDate)
            
            if let places = plan.places {
                
                locationNameLabel.text = "\(places.first!.city!), \(places.first!.country!)"
                
//                var allPlaces = ""
//                for place in places {
//                    allPlaces = allPlaces.stringByAppendingString("\(place.city!), ")
//                }
//                let cleanedPlaces = String(allPlaces.characters.dropLast(2))
            }

            
        }
//        weather()

    }
    
    func timerDidFire() {
        if let startDate = plan.startDate {
            startTimer(startDate)
        }
    }
    
    func startTimer(startDate: NSDate) {
        let today = NSDate()
        calendar.timeZone = NSTimeZone.localTimeZone()
        
        days = calendar.components(.Day, fromDate: today, toDate: startDate, options: []).day
        
        let startMinusDays = calendar.dateByAddingUnit(.Day, value: -days, toDate: startDate, options: [])
        
        hours = calendar.components(.Hour, fromDate: today, toDate: startMinusDays!, options: []).hour
        
        let startMinusHours = calendar.dateByAddingUnit(.Hour, value: -hours, toDate: startMinusDays!, options: [])

        minutes = calendar.components(.Minute, fromDate: today, toDate: startMinusHours!, options: []).minute
        
        let startMinusMinutes = calendar.dateByAddingUnit(.Minute, value: -minutes, toDate: startMinusHours!, options: [])
        
        seconds = calendar.components(.Second, fromDate: today, toDate: startMinusMinutes!, options: []).second
        
        if days > 0 || hours > 0 || minutes > 0 || seconds > 0 {
            startDaysLabel.text = days.description
            startHoursLabel.text = hours.description
            startMinutesLabel.text = minutes.description
            startSecondsLabel.text = seconds.description

        } else {
            startDaysLabel.text = "0"
            startHoursLabel.text = "0"
            startMinutesLabel.text = "0"
            startSecondsLabel.text = "0"
        }
    }
    
    func configureLabel(label: UILabel) {
        label.layer.borderColor = UIColor.plangoBackgroundGray().CGColor
        label.layer.borderWidth = 1
        
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        scrollView.contentSize = stackView.frame.size
//    }
    
    func didTapItinerary() {
        if plan.durationDays != nil && plan.durationDays != 0 && plan.startDate != nil && plan.endDate != nil {
            
            let itineraryVC = ItineraryViewController()
            itineraryVC.plan = self.plan
            self.showViewController(itineraryVC, sender: nil)
        } else {
            self.view.quickToast("No itinerary info for this plan")
        }
    }
    
    func didTapMap() {
        //TODO: - load map

    }
    
    

    
    func didTapFriends() {
        guard let members = plan.members else {self.view.quickToast("No members"); return}
        let membersVC = PlanMembersTableViewController()
        membersVC.members = members
        showViewController(membersVC, sender: nil)
    }
}
