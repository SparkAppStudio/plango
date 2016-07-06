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

class PlanSummaryViewController: UIViewController {

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
    
    // SummaryDetails xib
    @IBOutlet weak var detailsStartDateLabel: UILabel!
    @IBOutlet weak var detailsEndDateLabel: UILabel!
    @IBOutlet weak var detailsDescriptionLabel: UILabel!
    @IBOutlet weak var detailsTagsLabel: UILabel!
    
    
    var headerView: UIView!
    var startView: UIView!
    var detailsView: UIView!
    
    var scrollView: UIScrollView!
    var stackView: UIStackView!
    var buttonStackView: UIStackView!
    
    var plan: Plan!
    var myPlan: Bool! = false
    
    let calendar = NSCalendar.currentCalendar()
    var days = 0
    var hours = 0
    var minutes = 0
    var seconds = 0
    
    lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.snp_makeConstraints(closure: { (make) in
            make.size.equalTo(60)
        })
        button.backgroundColor = UIColor.plangoOrange()
        button.tintColor = UIColor.whiteColor()
        button.setTitle("Go Offline!", forState: UIControlState.Normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        button.setImage(UIImage(named: "download"), forState: .Normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.titleLabel?.font = UIFont.plangoButton()

        button.addTarget(self, action: #selector(didTapDownload), forControlEvents: .TouchUpInside)
        return button
    }()
    
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
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
//        button.setImage(UIImage(named: "friends-teal"), forState: .Normal)
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let plan = self.plan {
            if let user = Plango.sharedInstance.currentUser {
                if plan.authorID == user.id {
                    myPlan = true
                } else {
                    myPlan = false
                }
            }
        }
        
        let _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: true)
        
        let bundle = NSBundle(forClass: self.dynamicType)
        
        let nibHeader = UINib(nibName: "SummaryHeader", bundle: bundle)
        headerView = nibHeader.instantiateWithOwner(self, options: nil)[0] as! UIView
        headerView.snp_makeConstraints { (make) in
            make.height.equalTo(180)
        }
        
        let nibStart = UINib(nibName: "SummaryStart", bundle: bundle)
        startView = nibStart.instantiateWithOwner(self, options: nil)[0] as! UIView
        startView.snp_makeConstraints { (make) in
            make.height.equalTo(240)
        }
        
        let nibDetails = UINib(nibName: "SummaryDetails", bundle: bundle)
        detailsView = nibDetails.instantiateWithOwner(self, options: nil)[0] as! UIView
        detailsView.snp_makeConstraints { (make) in
            make.height.equalTo(180)
        }

        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.plangoBackgroundGray()
        view.addSubview(scrollView)
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .Vertical
        scrollView.addSubview(stackView)
        
        
        scrollView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        scrollView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        scrollView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        scrollView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        scrollView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        
        stackView.leadingAnchor.constraintEqualToAnchor(scrollView.leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(scrollView.trailingAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(scrollView.bottomAnchor).active = true
        stackView.topAnchor.constraintEqualToAnchor(scrollView.topAnchor).active = true
        stackView.widthAnchor.constraintEqualToAnchor(scrollView.widthAnchor).active = true

        if myPlan == true {
            stackView.addArrangedSubview(downloadButton)
        }
        stackView.addArrangedSubview(headerView)
        
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
        }
        
        stackView.addArrangedSubview(detailsView)
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
            
            detailsDescriptionLabel.text = plan.planDescription
                        
            var hashTags = ""
            var commaTags = ""
            guard let planTags = plan.tags else {
                return
            }
            for tagName in planTags {
                hashTags = hashTags.stringByAppendingString("#\(tagName) ")
                commaTags = commaTags.stringByAppendingString("\(tagName), ")
            }
            let cleanedTags = String(hashTags.characters.dropLast(1))
            detailsTagsLabel.text = cleanedTags
            
            let cleanedCommaTags = String(commaTags.characters.dropLast(2))
            tagsLabel.text = cleanedCommaTags
            
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
            guard let endDate = plan.endDate else {return}
            let formatter = NSDateFormatter()
            formatter.timeZone = NSTimeZone.defaultTimeZone()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            let startDateString = formatter.stringFromDate(startDate)
            let endDateString = formatter.stringFromDate(endDate)
            
            detailsStartDateLabel.text = startDateString
            detailsEndDateLabel.text = endDateString
            
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = stackView.frame.size
    }

    func didTapDownload() {
        //TODO: - download info to device
    }
    
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
