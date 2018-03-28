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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PlanSummaryViewController: UITableViewController {
    
    fileprivate enum SummaryTitles: String {
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
    @IBAction func didTapDownload(_ sender: UIButton) {
        guard (plan.experiences != nil) else {self.view.quickToast("No Experiences"); return}
        guard isMapDownloading() != true else {self.view.quickToast("Another Map is Downloading"); return}
        startOfflinePackDownload()

    }
    
    @IBOutlet weak var localPlanLabel: UILabel!
    @IBAction func didTapDeletePlan(_ sender: UIButton) {
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
    
    let downloader = ImageDownloader()
    var myGroup = DispatchGroup()
    
    var mapView: MGLMapView!
    
    lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
//        progress.frame = CGRectMake(UIScreen.mainScreen().bounds.width/4, UIScreen.mainScreen().bounds.height * 0.75 + 50, UIScreen.mainScreen().bounds.width/2, 20)
        progress.isHidden = true
        return progress
    }()
    
    fileprivate lazy var experiencePlaceDataSource = [String:Experience]()
    
    var timer: Timer!
    var calendar = Calendar.current
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
        button.backgroundColor = UIColor.white
        button.layer.borderColor = UIColor.plangoBackgroundGray().cgColor
        button.layer.borderWidth = 1
        button.tintColor = UIColor.plangoTeal()
        button.setTitleColor(UIColor.plangoTeal(), for: UIControlState())
        button.titleLabel?.font = UIFont.plangoSmallButton()
        button.setTitle("Itinerary", for: UIControlState())
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        button.setImage(UIImage(named: "itinerary-teal"), for: UIControlState())
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(didTapItinerary), for: .touchUpInside)
        return button
    }()
    
    lazy var mapButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.layer.borderColor = UIColor.plangoBackgroundGray().cgColor
        button.layer.borderWidth = 1

        button.tintColor = UIColor.plangoTeal()
        button.setTitleColor(UIColor.plangoTeal(), for: UIControlState())
        button.titleLabel?.font = UIFont.plangoSmallButton()
        button.setTitle("Map", for: UIControlState())
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        button.setImage(UIImage(named: "map-teal"), for: UIControlState())
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(didTapMap), for: .touchUpInside)
        return button
    }()
    
    lazy var friendsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.layer.borderColor = UIColor.plangoBackgroundGray().cgColor
        button.layer.borderWidth = 1

        button.tintColor = UIColor.plangoTeal()
        button.setTitleColor(UIColor.plangoTeal(), for: UIControlState())
        button.titleLabel?.font = UIFont.plangoSmallButton()
        button.setTitle("Friends", for: UIControlState())
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        button.setImage(UIImage(named: "friends-teal"), for: UIControlState())
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(didTapFriends), for: .touchUpInside)
        return button
    }()
    
    func weather() {
        
        let date = Date()
        var coordinate = CLLocationCoordinate2D(latitude: 117, longitude: 32)

        guard let experiences = plan.experiences else {return}
        
        
        for experience in experiences {
            guard let geo = experience.geocode else {continue}
            if geo.count > 1 {
                coordinate.latitude = geo.first!
                coordinate.longitude = geo.last!
                break

            } else {
                continue
            }
        }
        
        

        let rounder = NSDecimalNumberHandler(roundingMode: .bankers, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)

        
        let request = CZForecastioRequest.newForecastRequest(with: date)
        request?.key = "9c74ebb83e3387c347b8eb741b6402d5"
//        request.location = CZWeatherLocation(fromCity: "Sydney", country: "Australia")
//        request.location = CZWeatherLocation(fromCity: "Los Angeles", state: "CA")
        request?.location = CZWeatherLocation(from: coordinate)
        request?.send { (data, error) -> Void in
            if let error = error {
                self.printError(error as NSError)
            } else if let weather = data {
                let forecast = weather.dailyForecasts.first as! CZWeatherForecastCondition
                DispatchQueue.main.async(execute: { () -> Void in

                    print("high: \(forecast.highTemperature.f) low: \(forecast.lowTemperature.f)")
                    let avgTempFloat = (forecast.highTemperature.f + forecast.lowTemperature.f) / 2
                    let avgTemp = NSDecimalNumber(value: avgTempFloat as Float).rounding(accordingToBehavior: rounder)
                    
                    self.temperatureLabel.text = String(describing: avgTemp)
                    self.weatherLabel.text = forecast.summary
                    let climaChar = forecast.climacon.rawValue
                    let climaString = NSString(format: "%c", climaChar)
                    self.climaconLabel.text = String(climaString)
                    
                    self.temperatureLabel.isHidden = false
                    self.weatherLabel.isHidden = false
                    self.climaconLabel.isHidden = false
                    
                    self.temperatureLabel.dropShadow()
                    self.weatherLabel.dropShadow()
                    self.climaconLabel.dropShadow()
                })
            }
        }
    }
    
    func getOverviewStrings() {
        if let startDate = plan.startDate, let endDate = plan.endDate {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateStyle = DateFormatter.Style.long
            let startDateString = formatter.string(from: startDate as Date)
            let endDateString = formatter.string(from: endDate as Date)
            
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
    
    func deleteLocalPlan(_ plan: Plan) {
        
        let alert = UIAlertController(title: "Delete Local Data?", message: "Are you sure you want to remove this plan from your phone?", preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (action) in
            
            //realm
            let realm = try! Realm()
            if let object = realm.object(ofType: StoredPlan.self, forPrimaryKey: plan.id) {
                try! realm.write {
                    realm.delete(object)
                }
            }
            
            //mapbox
            for pack in MGLOfflineStorage.shared().packs! {
                guard let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? NSDictionary else {continue}
                guard let planID = userInfo["planID"] as? String else {continue}
                
                if planID == plan.id {
                    self.view.showSimpleLoading()
                    MGLOfflineStorage.shared().removePack(pack, withCompletionHandler: { (error) in
                        self.view.hideSimpleLoading()
                        if let error = error {
                            self.printError(error as NSError)
                        } else {
                            self.planDownloaded = false

                            self.progressView.isHidden = true
                            self.deleteView.removeFromSuperview()
                            self.stackView.addArrangedSubview(self.downloadView)
                        }
                    })
                    break
                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func isMapDownloading() -> Bool {
        guard let localPacks = MGLOfflineStorage.shared().packs else { return false }
        for pack in localPacks {
            if pack.state == .active {
                return true
            }
        }
        return false
    }
    
    func isPlanLocal(_ plan: Plan) -> Bool {
        guard let localPacks = MGLOfflineStorage.shared().packs else { return false }
        for pack in localPacks {
            guard let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? NSDictionary else {continue}
            guard let planID = userInfo["planID"] as? String else {continue}
            
            if planID == plan.id {
                
                let realm = try! Realm()
                if let object = realm.object(ofType: StoredPlan.self, forPrimaryKey: plan.id) {
                    if let map = object.mapSize {
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.localPlanLabel.text = "Delete this map to free up storage (\(map))"
                        })
                    }
                }
                
                return true
            }
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
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
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: true)
        
//        let bundle = NSBundle(forClass: self.dynamicType)
        
        let nibHeader = UINib(nibName: "SummaryHeader", bundle: nil)
        headerView = nibHeader.instantiate(withOwner: self, options: nil)[0] as! UIView
        headerView.snp.makeConstraints { (make) in
            make.height.equalTo(Helper.CellHeight.superWide.value)
        }
        
        let nibStart = UINib(nibName: "SummaryStart", bundle: nil)
        startView = nibStart.instantiate(withOwner: self, options: nil)[0] as! UIView
        startView.snp.makeConstraints { (make) in
            make.height.equalTo(200)
        }
        
        let nibDownload = UINib(nibName: "DownloadView", bundle: nil)
        downloadView = nibDownload.instantiate(withOwner: self, options: nil)[0] as! UIView
        downloadView.snp.makeConstraints { (make) in
            make.height.equalTo(160)
        }
        
        let nibDelete = UINib(nibName: "DeletePlanView", bundle: nil)
        deleteView = nibDelete.instantiate(withOwner: self, options: nil)[0] as! UIView
        deleteView.snp.makeConstraints { (make) in
            make.height.equalTo(160)
        }
        

        
        // headerfooter view is like a cell
        let sectionNib = UINib(nibName: "SectionHeader", bundle: nil)
        self.tableView.register(sectionNib, forHeaderFooterViewReuseIdentifier: CellID.Header.rawValue)
        
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: CellID.Footer.rawValue)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Start")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Overview")
        
        let experienceNib = UINib(nibName: "ExperienceCell", bundle: nil)
        tableView.register(experienceNib, forCellReuseIdentifier: CellID.Experience.rawValue)

        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: Helper.CellHeight.superWide.value))
        
        containerView.addSubview(headerView)
        
        headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        headerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        
        tableView.tableHeaderView = containerView


//        scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.backgroundColor = UIColor.plangoBackgroundGray()
//        view.addSubview(scrollView)
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
//        scrollView.addSubview(stackView)
        
        
//        scrollView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
//        scrollView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
//        scrollView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
//        scrollView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
//        scrollView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        
        buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
//        buttonStackView.spacing = 4
        buttonStackView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
        }
        
        buttonStackView.addArrangedSubview(itineraryButton)
        buttonStackView.addArrangedSubview(mapButton)
        if myPlan == true {
            buttonStackView.addArrangedSubview(friendsButton)
            
            buttonStackView.addSubview(progressView)
            progressView.snp.makeConstraints({ (make) in
                make.top.equalTo(buttonStackView.snp.bottom)
                make.height.equalTo(12)
                make.leading.equalTo(buttonStackView.snp.leading)
                make.trailing.equalTo(buttonStackView.snp.trailing)
            })
        }
        
        stackView.addArrangedSubview(buttonStackView)
        
        //determine differences in view based on plan specifics, must be after nibs have been created
        if myPlan == true {
            setupDownload()
            stackView.addArrangedSubview(startView)
            
            planDownloaded = isPlanLocal(plan)
            if planDownloaded == false {
                stackView.addArrangedSubview(downloadView)
            } else {
                stackView.addArrangedSubview(deleteView)
            }
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let places = plan.places else {return SummaryTitles.count}
        return SummaryTitles.count + places.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SummaryTitles.Start.section:
            return 1
        case SummaryTitles.Overview.section:
            return overviewTextArray.count
        default:
            guard let places = plan.places else {return 0}
            let placeID = places[section - 2].id //subtract 2 because of 1st 2 hard coded sections
            guard let experiences = experiencesByPlace[placeID!] else {return 0}
            return experiences.count
            
            //            if experiences.count < 3 {
            //                return experiences.count
            //            } else {
            //                return 3
            //            }
        }
    }
    
    var overviewTextArray = [String]()
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SummaryTitles.Start.section:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Start", for: indexPath)
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = UIColor.plangoBackgroundGray()
            cell.contentView.addSubview(stackView)
            
            stackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            stackView.widthAnchor.constraint(equalTo: cell.contentView.widthAnchor).isActive = true

            return cell
        case SummaryTitles.Overview.section:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Overview", for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.font = UIFont.plangoBodyBig()
            cell.textLabel?.textColor = UIColor.plangoText()
            cell.textLabel?.text = overviewTextArray[indexPath.row]

            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellID.Experience.rawValue, for: indexPath) as! ExperienceTableViewCell
            
            guard let places = plan.places else {return cell}
            let placeID = places[indexPath.section - 2].id
            guard let experiences = experiencesByPlace[placeID!] else {return cell}
            
            cell.experience = experiences[indexPath.row]
            cell.configure()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case SummaryTitles.Start.section:
            if myPlan == true {
                if timer != nil {
                    return 50 + 200 + 160 + 24 //buttonstackview + startview + download + spacing
                } else { //no startview
                    return 50 + 160 + 12 //buttonstackview + download + spacing
                }
                
            } else {
                return 50 //buttonstackview
            }
        case SummaryTitles.Overview.section:
            return UITableViewAutomaticDimension
        default:
            return Helper.CellHeight.reviews.value
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellID.Footer.rawValue)
        footerView?.isHidden = true
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func parseExperiencesIntoPlaces(_ experiences: [Experience]?, places: [Place]?) -> [String:[Experience]] {
        var placesExperiences = [String:[Experience]]()
        guard let places = places, let experiences = experiences else {return placesExperiences}
        
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellID.Header.rawValue) as! SectionHeaderView
        
        switch section {
        case SummaryTitles.Start.section:
            return nil
        case SummaryTitles.Overview.section:
            headerView.titleLabel.text = "Overview"
            
            if let cities = plan.places?.count {
                headerView.citiesLabel.isHidden = false
                headerView.citiesImageView.isHidden = false
                if cities == 1 {
                    headerView.citiesLabel.text = "\(cities) City"
                } else {
                    headerView.citiesLabel.text = "\(cities) Cities"
                }
            }
            
            if let duration = plan.durationDays {
                headerView.daysLabel.isHidden = false
                headerView.daysImageView.isHidden = false
                if duration == 1 {
                    headerView.daysLabel.text = "\(duration) Day"
                } else {
                    headerView.daysLabel.text = "\(duration) Days"
                }
            }
            
            if let activities = plan.experiences?.count {
                headerView.activitiesLabel.isHidden = false
                headerView.activitiesImageView.isHidden = false
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
                headerView.daysLabel.isHidden = false
                headerView.daysImageView.isHidden = false

                if duration == 1 {
                    headerView.daysLabel.text = "\(duration) Day"
                } else {
                    headerView.daysLabel.text = "\(duration) Days"
                }
            }
            
            if let activities = experiencesByPlace[place.id]?.count {
                headerView.activitiesLabel.isHidden = false
                headerView.activitiesImageView.isHidden = false

                if activities == 1 {
                    headerView.activitiesLabel.text = "\(activities) Activity"
                } else {
                    headerView.activitiesLabel.text = "\(activities) Activities"
                }
            }
            
            return headerView
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case SummaryTitles.Start.section:
            return 0
        case SummaryTitles.Overview.section:
            return Helper.HeaderHeight.section.value
        default:
            return Helper.HeaderHeight.section.value
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 1 {
            let cell = tableView.cellForRow(at: indexPath) as! ExperienceTableViewCell
            let eventDetails = EventDetailsTableViewController()
            eventDetails.experience = cell.experience
            
            show(eventDetails, sender: nil)

        }
    }
    
    func parseTags(_ planTags: [String], comma: Bool) -> String {
        
        var tags = ""

        for tagName in planTags {
            if comma == true {
                tags = tags + "\(tagName), "
            } else {
                tags = tags + "#\(tagName) "
            }
        }
        
        if comma == true {
            return String(tags.dropLast(2))
        } else {
            return String(tags.dropLast(1))
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        configureLabel(startDaysLabel)
        configureLabel(startHoursLabel)
        configureLabel(startMinutesLabel)
        configureLabel(startSecondsLabel)
        
        if let plan = self.plan {
            self.navigationItem.title = plan.name?.uppercased()
            
            coverImageView.plangoImage(plan)
            
            if let tags = plan.tags {
                tagsLabel.text = parseTags(tags, comma: true)
            }
            
            if let places = plan.places {
                
                var locationText = String()
                if let city = places.first?.city {
                    locationText = city
                }
                if let country = places.first?.country {
                    locationText = locationText + ", \(country)"
                }
                locationNameLabel.text = locationText
                
                //                var allPlaces = ""
                //                for place in places {
                //                    allPlaces = allPlaces.stringByAppendingString("\(place.city!), ")
                //                }
                //                let cleanedPlaces = String(allPlaces.characters.dropLast(2))
            }
                        
            guard let days = plan.durationDays else {durationLabel.isHidden = true; return}
            
            if days == 1 {
                durationLabel.text = "\(days.description) Day"
            } else {
                durationLabel.text = "\(days.description) Days"
            }
            
            guard let startDate = plan.startDate else {return}
            startTimer(startDate as Date)
        }
        weather()

    }
    
    
    func stopTimer() {
        guard timer != nil else { return }
        timer.invalidate()
        timer = nil
    }
    
    @objc func timerDidFire() {
        if let startDate = plan.startDate {
            startTimer(startDate as Date)
        }
    }
    
    func startTimer(_ startDate: Date) {
        let today = Date()
        calendar.timeZone = TimeZone.autoupdatingCurrent

        days = calendar.dateComponents([.day], from: today, to: startDate).day!

        let startMinusDays = calendar.date(byAdding: .day, value: -days, to: startDate)
        
        hours = calendar.dateComponents([.hour], from: today, to: startMinusDays!).hour!
        
        let startMinusHours = calendar.date(byAdding: .hour, value: -hours, to: startMinusDays!)

        minutes = calendar.dateComponents([.minute], from: today, to: startMinusHours!).minute!
        
        let startMinusMinutes = calendar.date(byAdding: .minute, value: -minutes, to: startMinusHours!)
        
        seconds = calendar.dateComponents([.second], from: today, to: startMinusMinutes!).second!
        
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
            
            stopTimer()
            startView.removeFromSuperview()
            tableView.reloadData()
        }
    }
    
    func configureLabel(_ label: UILabel) {
        label.layer.borderColor = UIColor.plangoBackgroundGray().cgColor
        label.layer.borderWidth = 1
        
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        scrollView.contentSize = stackView.frame.size
//    }
    
    @objc func didTapItinerary() {
        guard (plan.experiences?.count > 0) else {self.view.quickToast("No Activities for this Plan"); return}
        let itineraryVC = ItineraryViewController()
        itineraryVC.plan = self.plan
        self.show(itineraryVC, sender: nil)
    }
    
    @objc func didTapMap() {
        guard (plan.experiences?.count > 0) else {self.view.quickToast("No Activities for this Plan"); return}
        displayMapForPlan(plan, download: false)
    }
    
    

    
    @objc func didTapFriends() {
        guard let members = plan.members else {self.view.quickToast("No Members"); return}
        let membersVC = PlanMembersTableViewController()
        membersVC.members = members
        show(membersVC, sender: nil)
    }
    
    //MARK: - Map Download without viewing map
    
    deinit {
        //        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        if myPlan == true {
            MGLOfflineStorage.shared().removeObserver(self, forKeyPath: "packs")
        }
        NotificationCenter.default.removeObserver(self)
    }
}

extension PlanSummaryViewController: MGLMapViewDelegate {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "packs" {
            if let change = change {
                let changeObject = change[NSKeyValueChangeKey.kindKey] as AnyObject

                let kind = changeObject.uintValue
                if kind == NSKeyValueChange.setting.rawValue {
                    
                    //only check if its false, to perhaps prevent double firing
                    if planDownloaded == false {
                        //run the method again now that maps are known to be not nil
                        planDownloaded = isPlanLocal(plan)
                        
                        //if its still false do nothing, if its now true, switch the views
                        if planDownloaded == true {
                            downloadView.removeFromSuperview()
                            stackView.addArrangedSubview(deleteView)
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    func cachePlanImages(_ plan: Plan) {
        downloadImage(plan)
        guard let experiences = plan.experiences else {return}
        for experience in experiences {
            downloadImage(experience)
            guard let reviews = experience.reviews else {continue}
            for review in reviews {
                downloadImage(review)
            }
        }
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            StoredPlan.savePlan(plan, mapSize: "72.7Mb") //avg size when we dont know the actual size because user let download finish on another screen
        })
    }
    
    func downloadImage(_ object: PlangoObject) {
        guard let endPoint = object.avatar else {return}
        guard let cleanURL = URL(string: Plango.sharedInstance.cleanEndPoint(endPoint)) else {return}
        myGroup.enter()

        //download and set avatar
        let request = URLRequest(url: cleanURL)
        downloader.download(request, completion: { (response) in
            self.myGroup.leave()
            if response.result.isSuccess {
                if let image = response.result.value {
                    let imageData = UIImageJPEGRepresentation(image, 1.0)
                    object.localAvatar = imageData
                }
            }
        })
    }
    
    func setupDownload() {
        mapView = MGLMapView(frame: self.view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        
        let pointsAndPlaces = MapViewController.getPlacesFromExperiences(plan.experiences)
        let points = pointsAndPlaces.points
        experiencePlaceDataSource = pointsAndPlaces.places
        
        if points.count > 0 {
            mapView.addAnnotations(points)
            mapView.showAnnotations(points, animated: false)
        }
        
        if points.count == 1 {
            mapView.zoomLevel = 14
        }
        
        MGLOfflineStorage.shared().addObserver(self, forKeyPath: "packs", options: NSKeyValueObservingOptions.new, context: nil)
        
        // Setup offline pack notification handlers.
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.offlinePackProgressDidChange(_:)), name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.offlinePackDidReceiveError(_:)), name: NSNotification.Name.MGLOfflinePackError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.offlinePackDidReceiveMaximumAllowedMapboxTiles(_:)), name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached, object: nil)
        
    }
    
    func startOfflinePackDownload() {
        
        guard let plan = plan else {return} //no plan no download
        
        //images for realm in case user hasn't already scrolled to make them appear and download, also save plan to realm in case user navigates away from this controller before map finishes
        cachePlanImages(plan)

        
        // create region to save based on current map locations and also how far the user can zoom in
        let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: mapView.visibleCoordinateBounds, fromZoomLevel: mapView.zoomLevel, toZoomLevel: mapView.zoomLevel + 3)
        // zoom level + 3 is minimum. Any less you dont save much space but map is less useful. 4 might be a better level but then space and time to download are increased.
        
        //metadata for local storage
        let userInfo: NSDictionary = ["planID" : plan.id]
        let context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
        
        //create and regsiter offline pack with the shared singleton storage object
        MGLOfflineStorage.shared().addPack(for: region, withContext: context) { (pack, error) in
            guard error == nil else {
                self.printError(error! as NSError)
                return
            }
            //start downloading
            pack?.resume()
        }
    }
    
    // MARK: - MGLOfflinePack notification handlers
    
    func offlinePackProgressDidChange(_ notification: Foundation.Notification) {
        // Get the offline pack this notification is regarding,
        // and the associated user info for the pack; in this case, `name = My Offline Pack`
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String] {
            let progress = pack.progress
            // or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
            let completedResources = progress.countOfResourcesCompleted
            let expectedResources = progress.countOfResourcesExpected
            
            // Calculate current progress percentage.
            let progressPercentage = Float(completedResources) / Float(expectedResources)
            
            // Setup the progress bar if its right plan controller
            if userInfo["planID"] == plan.id {
                progressView.isHidden = false
                progressView.progress = progressPercentage
            }
            
            
            // If this pack has finished, print its size and resource count.
            let name = userInfo["name"] ?? "name not found"
            if completedResources == expectedResources {
                progressView.isHidden = true
                let byteCount = ByteCountFormatter.string(fromByteCount: Int64(pack.progress.countOfBytesCompleted), countStyle: ByteCountFormatter.CountStyle.memory)

                //check and make sure user is on correct plan controller viewing the plan that is being downloaded
                if userInfo["planID"] == plan.id {
                    self.view.imageToast(nil, image: UIImage(named: "whiteCheck")!, notify: false)
                    
                    localPlanLabel.text = "Delete this map to free up storage (\(byteCount))"
                    
                    StoredPlan.savePlan(plan, mapSize: byteCount)
                    
                    self.planDownloaded = true
                    downloadView.removeFromSuperview()
                    stackView.addArrangedSubview(deleteView)

                } else {
                    self.view.quickToast("Your other plan finished downloading") //realm plan wont know how big map data is to display but otherwise will work fine
                }
                
                print("Offline pack “\(name)” completed: \(byteCount), \(completedResources) resources")
            } else {
                // Otherwise, print download/verification progress.
                print("Offline pack “\(name)” has \(completedResources) of \(expectedResources) resources — \(progressPercentage * 100)%.")
            }
        }
    }
    
    func offlinePackDidReceiveError(_ notification: Foundation.Notification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let error = notification.userInfo?[MGLOfflinePackUserInfoKey.error] as? NSError {
            let name = userInfo["name"] ?? "name not found"
            print("Offline pack “\(name)” received error: \(String(describing: error.localizedFailureReason))")
        }
    }
    
    func offlinePackDidReceiveMaximumAllowedMapboxTiles(_ notification: Foundation.Notification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let maximumCount = (notification.userInfo?[MGLOfflinePackUserInfoKey.maximumCount] as AnyObject).uint64Value {
            let name = userInfo["name"] ?? "name not found"
            print("Offline pack “\(name)” reached limit of \(maximumCount) tiles.")
        }
    }
    
//    func getPlacesFromExperiences(experiences: [Experience]?) -> [MGLPointAnnotation] {
//        var points = [MGLPointAnnotation]()
//        guard let experiences = experiences else {return points}
//        
//        for experience in experiences {
//            guard let latitute: CLLocationDegrees = experience.geocode?.first else {continue}
//            guard let longitute: CLLocationDegrees = experience.geocode?.last else {continue}
//            
//            let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
//            
//            let point = MGLPointAnnotation()
//            point.coordinate = coordinates
//            
//            if let details = experience.experienceDescription {
//                point.subtitle = details
//            }
//            if let name = experience.name {
//                point.title = name
//                experiencePlaceDataSource[name] = experience
//            }
//            points.append(point)
//        }
//        return points
//    }
}
