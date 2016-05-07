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
    
    
    var headerView: UIView!
    var scrollView: UIScrollView!
    var stackView: UIStackView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "SummaryHeader", bundle: bundle)
        headerView = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        headerView.snp_makeConstraints { (make) in
            make.height.equalTo(180)
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

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let plan = self.plan {
            self.navigationItem.title = plan.name
            
            guard let endPoint = plan.avatar else {coverImageView.backgroundColor = UIColor.plangoTeal(); return}
            print(endPoint)
            let cleanURL = NSURL(string: Plango.sharedInstance.cleanEndPoint(endPoint))
            coverImageView.af_setImageWithURL(cleanURL!)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = stackView.frame.size
    }

    func didTapDownload() {
        //TODO: - download info to device
    }
}
