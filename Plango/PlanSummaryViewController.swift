//
//  PlanSummaryViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import SnapKit

class PlanSummaryViewController: UIViewController {

    var scrollView: UIScrollView!
    var stackView: UIStackView!
    
    lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.snp_makeConstraints(closure: { (make) in
            make.size.equalTo(100)
        })
        button.backgroundColor = UIColor.plangoOrange()
        button.tintColor = UIColor.whiteColor()
        button.setTitle("Log In", forState: UIControlState.Normal)
        button.makeRoundCorners(64)
        button.addTarget(self, action: #selector(didTapDownload), forControlEvents: .TouchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = stackView.frame.size
    }

    func didTapDownload() {
        //TODO: - download info to device
    }
}
