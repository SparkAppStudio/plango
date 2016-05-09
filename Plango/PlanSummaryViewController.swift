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

class PlanSummaryViewController: UIViewController {

    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var startDaysLabel: UILabel!
    @IBOutlet weak var startHoursLabel: UILabel!
    @IBOutlet weak var startSecondsLabel: UILabel!
    
    
    
    var headerView: UIView!
    var startView: UIView!
    var detailsView: UIView!
    
    var scrollView: UIScrollView!
    var stackView: UIStackView!
    var buttonStackView: UIStackView!
    
    var plan: Plan!
    
    lazy var downloadButton: UIButton = {
        let button = UIButton()
//        button.snp_makeConstraints(closure: { (make) in
//            make.size.equalTo(30)
//        })
        button.backgroundColor = UIColor.plangoOrange()
        button.tintColor = UIColor.whiteColor()
        button.setTitle("Download Plan", forState: UIControlState.Normal)
        button.makeRoundCorners(64)
        button.addTarget(self, action: #selector(didTapDownload), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var itineraryButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = UIColor.whiteColor()
        button.layer.borderColor = UIColor.plangoBrown().CGColor
        button.layer.borderWidth = 1
        button.tintColor = UIColor.plangoBrown()
        button.setTitleColor(UIColor.plangoBrown(), forState: .Normal)
        button.setTitle("Itinerary", forState: .Normal)
        button.addTarget(self, action: #selector(didTapItinerary), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var mapButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.whiteColor()
        button.layer.borderColor = UIColor.plangoBrown().CGColor
        button.layer.borderWidth = 1

        button.tintColor = UIColor.plangoBrown()
        button.setTitleColor(UIColor.plangoBrown(), forState: .Normal)
        button.setTitle("Map", forState: .Normal)
        button.addTarget(self, action: #selector(didTapMap), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var friendsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.whiteColor()
        button.layer.borderColor = UIColor.plangoBrown().CGColor
        button.layer.borderWidth = 1

        button.tintColor = UIColor.plangoBrown()
        button.setTitleColor(UIColor.plangoBrown(), forState: .Normal)
        button.setTitle("Friends", forState: .Normal)
        button.addTarget(self, action: #selector(didTapFriends), forControlEvents: .TouchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            make.height.equalTo(320)
        }

        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.plangoCream()
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

        stackView.addArrangedSubview(downloadButton)
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
        buttonStackView.addArrangedSubview(friendsButton)
        
        stackView.addArrangedSubview(buttonStackView)
        
        stackView.addArrangedSubview(startView)
        stackView.addArrangedSubview(detailsView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureLabel(startDaysLabel)
        configureLabel(startHoursLabel)
        configureLabel(startSecondsLabel)
        
        if let plan = self.plan {
            self.navigationItem.title = plan.name
            
            guard let endPoint = plan.avatar else {coverImageView.backgroundColor = UIColor.plangoTeal(); return}
            print(endPoint)
            let cleanURL = NSURL(string: Plango.sharedInstance.cleanEndPoint(endPoint))
            coverImageView.af_setImageWithURL(cleanURL!)
        }
    }
    
    func configureLabel(label: UILabel) {
        label.layer.borderColor = UIColor.plangoBrown().CGColor
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
        //TODO: - load itinerary

    }
    
    func didTapMap() {
        //TODO: - load map

    }
    
    func didTapFriends() {
        //TODO: - load friends

    }
}
