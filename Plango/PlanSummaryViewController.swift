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
import Mapbox
import RealmSwift

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
    @IBOutlet weak var coverImageView: CompoundImageView!
    
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
        guard (plan.experiences != nil) else {self.view.quickToast("No Experiences"); return}
        startOfflinePackDownload()

    }
    
    @IBOutlet weak var localPlanLabel: UILabel!
    @IBAction func didTapDeletePlan(sender: UIButton) {
        deleteLocalPlan(plan)
    }
    
    var headerView: UIView!
    var startView: UIView!
    var detailsView: UIView!
    var downloadView: UIView!
    var deleteView: UIView!
    
    var stackView: UIStackView!
    var buttonStackView: UIStackView!
    
    var plan: Plan!
    var myPlan: Bool! = false
    var planDownloaded: Bool! = false
    
    var experiencesByPlace: [String:[Experience]]!
    
    var timer: NSTimer!
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
    
    func deleteLocalPlan(plan: Plan) {
        
        let alert = UIAlertController(title: "Delete Local Data?", message: "Are you sure you want to remove this plan from your phone?", preferredStyle: .Alert)
        
        let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive) { (action) in
            
            //realm
            let realm = try! Realm()
            if let object = realm.objectForPrimaryKey(StoredPlan.self, key: plan.id) {
                try! realm.write {
                    realm.delete(object)
                }
            }
            
            //mapbox
            for pack in MGLOfflineStorage.sharedOfflineStorage().packs! {
                guard let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(pack.context) as? NSDictionary else {continue}
                guard let planID = userInfo["planID"] as? String else {continue}
                
                if planID == plan.id {
                    self.view.showSimpleLoading()
                    MGLOfflineStorage.sharedOfflineStorage().removePack(pack, withCompletionHandler: { (error) in
                        self.view.hideSimpleLoading()
                        if let error = error {
                            self.printError(error)
                        } else {
                            self.planDownloaded = false
                            self.deleteView.removeFromSuperview()
                            self.stackView.addArrangedSubview(self.downloadView)
                        }
                    })
                    break
                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func isPlanLocal(plan: Plan) -> Bool {
        guard let localPacks = MGLOfflineStorage.sharedOfflineStorage().packs else { return false }
        for pack in localPacks {
            guard let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(pack.context) as? NSDictionary else {continue}
            guard let planID = userInfo["planID"] as? String else {continue}
            
            if planID == plan.id {
                
                let realm = try! Realm()
                if let object = realm.objectForPrimaryKey(StoredPlan.self, key: plan.id) {
                    localPlanLabel.text = "Delete this map to free up storage (\(object.mapSize))"
                }
                
                return true
            }
        }
        return false
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
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: true)
        
//        let bundle = NSBundle(forClass: self.dynamicType)
        
        let nibHeader = UINib(nibName: "SummaryHeader", bundle: nil)
        headerView = nibHeader.instantiateWithOwner(self, options: nil)[0] as! UIView
        headerView.snp_makeConstraints { (make) in
            make.height.equalTo(Helper.CellHeight.superWide.value)
        }
        
        let nibStart = UINib(nibName: "SummaryStart", bundle: nil)
        startView = nibStart.instantiateWithOwner(self, options: nil)[0] as! UIView
        startView.snp_makeConstraints { (make) in
            make.height.equalTo(200)
        }
        
        let nibDownload = UINib(nibName: "DownloadView", bundle: nil)
        downloadView = nibDownload.instantiateWithOwner(self, options: nil)[0] as! UIView
        downloadView.snp_makeConstraints { (make) in
            make.height.equalTo(160)
        }
        
        let nibDelete = UINib(nibName: "DeletePlanView", bundle: nil)
        deleteView = nibDelete.instantiateWithOwner(self, options: nil)[0] as! UIView
        deleteView.snp_makeConstraints { (make) in
            make.height.equalTo(160)
        }
        
        planDownloaded = isPlanLocal(plan)

        
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
            setupDownload()
            stackView.addArrangedSubview(startView)
            if planDownloaded == false {
                stackView.addArrangedSubview(downloadView)
            } else {
                stackView.addArrangedSubview(deleteView)
            }
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
            return Helper.CellHeight.reviews.value
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(CellID.Footer.rawValue)
        footerView?.hidden = true
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
            return Helper.HeaderHeight.section.value
        default:
            return Helper.HeaderHeight.section.value
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
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        guard timer != nil else { return }
        timer.invalidate()
        timer = nil
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
                coverImageView.gradientDarkToClear()
            } else {coverImageView.backgroundColor = UIColor.plangoTeal()}
            
            if let tags = plan.tags {
                tagsLabel.text = parseTags(tags, comma: true)
            }
            
            if let places = plan.places {
                
                var locationText = String()
                if let city = places.first?.city {
                    locationText = city
                }
                if let country = places.first?.country {
                    locationText = locationText.stringByAppendingString(", \(country)")
                }
                locationNameLabel.text = locationText
                
                //                var allPlaces = ""
                //                for place in places {
                //                    allPlaces = allPlaces.stringByAppendingString("\(place.city!), ")
                //                }
                //                let cleanedPlaces = String(allPlaces.characters.dropLast(2))
            }
                        
            guard let days = plan.durationDays else {durationLabel.hidden = true; return}
            
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
        print(plan.experiences)
        guard (plan.experiences?.count > 0) else {self.view.quickToast("No Activities for this Plan"); return}
        let itineraryVC = ItineraryViewController()
        itineraryVC.plan = self.plan
        self.showViewController(itineraryVC, sender: nil)
    }
    
    func didTapMap() {
        guard (plan.experiences?.count > 0) else {self.view.quickToast("No Activities for this Plan"); return}
        displayMapForPlan(plan, download: false)
    }
    
    

    
    func didTapFriends() {
        guard let members = plan.members else {self.view.quickToast("No Members"); return}
        let membersVC = PlanMembersTableViewController()
        membersVC.members = members
        showViewController(membersVC, sender: nil)
    }
    
    //MARK: - Map Download without viewing map
    
    deinit {
        //        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    var mapView: MGLMapView!
    var progressView: UIProgressView!
    
    private lazy var experiencePlaceDataSource = [String:Experience]()


}

extension PlanSummaryViewController: MGLMapViewDelegate {
    
    func setupDownload() {
        mapView = MGLMapView(frame: self.view.bounds)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        mapView.delegate = self
        
        let places = getPlacesFromExperiences(plan.experiences)
        
        if places.count > 0 {
            mapView.addAnnotations(places)
            mapView.showAnnotations(places, animated: false)
        }
        
        if places.count == 1 {
            mapView.zoomLevel = 14
        }
        
        // Setup offline pack notification handlers.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.offlinePackProgressDidChange(_:)), name: MGLOfflinePackProgressChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.offlinePackDidReceiveError(_:)), name: MGLOfflinePackErrorNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.offlinePackDidReceiveMaximumAllowedMapboxTiles(_:)), name: MGLOfflinePackMaximumMapboxTilesReachedNotification, object: nil)
        
    }
    
    func startOfflinePackDownload() {
        // create region to save based on current map locations and also how far the user can zoom in
        let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: mapView.visibleCoordinateBounds, fromZoomLevel: mapView.zoomLevel, toZoomLevel: mapView.zoomLevel + 3)
        print(mapView.zoomLevel)
        guard let plan = plan else {return}
        //metadata for local storage
        let userInfo: NSDictionary = ["planID" : plan.id]
        let context = NSKeyedArchiver.archivedDataWithRootObject(userInfo)
        
        //create and regsiter offline pack with the shared singleton storage object
        MGLOfflineStorage.sharedOfflineStorage().addPackForRegion(region, withContext: context) { (pack, error) in
            guard error == nil else {
                self.printError(error!)
                return
            }
            //start downloading
            pack?.resume()
        }
    }
    
    // MARK: - MGLOfflinePack notification handlers
    
    func offlinePackProgressDidChange(notification: NSNotification) {
        // Get the offline pack this notification is regarding,
        // and the associated user info for the pack; in this case, `name = My Offline Pack`
        if let pack = notification.object as? MGLOfflinePack,
            userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(pack.context) as? [String: String] {
            let progress = pack.progress
            // or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
            let completedResources = progress.countOfResourcesCompleted
            let expectedResources = progress.countOfResourcesExpected
            
            // Calculate current progress percentage.
            let progressPercentage = Float(completedResources) / Float(expectedResources)
            
            // Setup the progress bar.
            if progressView == nil {
                progressView = UIProgressView(progressViewStyle: .Default)
                let frame = view.bounds.size
                progressView.frame = CGRectMake(frame.width / 4, frame.height * 0.75 + 50, frame.width / 2, 10)
                view.addSubview(progressView)
            } else {
                progressView.hidden = false
            }
            
            progressView.progress = progressPercentage
            
            // If this pack has finished, print its size and resource count.
            if completedResources == expectedResources {
                //                self.navigationController?.popViewControllerAnimated(true)
                progressView.hidden = true
                self.mapView.imageToast(nil, image: UIImage(named: "whiteCheck")!, notify: false)
                
                let byteCount = NSByteCountFormatter.stringFromByteCount(Int64(pack.progress.countOfBytesCompleted), countStyle: NSByteCountFormatterCountStyle.Memory)
                localPlanLabel.text = "Delete this map to free up storage (\(byteCount))"
                
                StoredPlan.savePlan(plan, mapSize: byteCount)
                
                self.planDownloaded = true
                downloadView.removeFromSuperview()
                stackView.addArrangedSubview(deleteView)
                
                
                print("Offline pack “\(userInfo["name"])” completed: \(byteCount), \(completedResources) resources")
            } else {
                // Otherwise, print download/verification progress.
                print("Offline pack “\(userInfo["name"])” has \(completedResources) of \(expectedResources) resources — \(progressPercentage * 100)%.")
            }
        }
    }
    
    func offlinePackDidReceiveError(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(pack.context) as? [String: String],
            error = notification.userInfo?[MGLOfflinePackErrorUserInfoKey] as? NSError {
            print("Offline pack “\(userInfo["name"])” received error: \(error.localizedFailureReason)")
        }
    }
    
    func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(pack.context) as? [String: String],
            maximumCount = notification.userInfo?[MGLOfflinePackMaximumCountUserInfoKey]?.unsignedLongLongValue {
            print("Offline pack “\(userInfo["name"])” reached limit of \(maximumCount) tiles.")
        }
    }
    
    func getPlacesFromExperiences(experiences: [Experience]?) -> [MGLPointAnnotation] {
        var points = [MGLPointAnnotation]()
        guard let experiences = experiences else {return points}
        
        for experience in experiences {
            guard let latitute: CLLocationDegrees = experience.geocode?.first else {break}
            guard let longitute: CLLocationDegrees = experience.geocode?.last else {break}
            
            let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
            
            let point = MGLPointAnnotation()
            point.coordinate = coordinates
            
            if let details = experience.experienceDescription {
                point.subtitle = details
            }
            if let name = experience.name {
                point.title = name
                experiencePlaceDataSource[name] = experience
            }
            points.append(point)
        }
        return points
    }
}
