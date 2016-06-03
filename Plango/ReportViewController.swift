//
//  ReportViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 5/13/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {
    
    @IBOutlet weak var reportTextView: UITextView!
    @IBOutlet weak var reportButton: UIButton!
    
    var plan: Plan!

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserverForName(Notify.Timer.rawValue, object: nil, queue: nil) { (notification) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reportButton.makeRoundCorners(64)
        reportButton.backgroundColor = UIColor.plangoOrange()
        reportButton.tintColor = UIColor.whiteColor()
        
        reportTextView.layer.borderWidth = 2
        reportTextView.layer.borderColor = UIColor.plangoBrown().CGColor
    }
    
    @IBAction func didTapReport(sender: UIButton) {
        if reportTextView.text.isEmpty == false {
            reportPlan(plan.id)
//            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.reportTextView.detailToast("No Reason for Objection", details: "Please tell us why you don't like this content.")
        }

    }
    
    func reportPlan(planID: String) {
        self.reportTextView.showSimpleLoading()
        Plango.sharedInstance.reportSpam(Plango.EndPoint.Report.rawValue, planID: planID) { (errorString) in
            self.reportTextView.hideSimpleLoading()
            
            guard let error = errorString else {
                self.reportTextView.imageToast("Successfully Sent", image: UIImage(named: "whiteCheck")!, notify: true)
                return
            }
            if let message = error.message {
                self.reportTextView.quickToast(message)
            }
            self.printPlangoError(error)
        }
    }

}
