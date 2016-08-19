//
//  PlanListTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift

class PlansTableViewController: UITableViewController {
    
    lazy var plansArray = [Plan]()
    
    //search criteria "\(parent.selectedTags?.description) in \(parent.selectedDestinations?.description) for \(parent.minDuration) - \(parent.maxDuration) days"
    
    lazy var backgroundLabel: UILabel = {
        let backgroundLabel = UILabel(frame: self.tableView.frame)
        if self.findPlansParameters == nil { //nil means its MyPlans, not search
            backgroundLabel.text = "You have no plans. Create a new one on the desktop at plango.us"
        } else {
            backgroundLabel.text = "0 results found"
        }
        backgroundLabel.numberOfLines = 0
        backgroundLabel.font = UIFont.plangoSectionHeader()
        backgroundLabel.textColor = UIColor.plangoTypeSectionHeaderGray()
        backgroundLabel.textAlignment = .Center
        backgroundLabel.backgroundColor = UIColor.plangoBackgroundGray()
        return backgroundLabel
    }()
    
    var fetchRequest: Request?
    var currentFetchPage: Int = 0
    var endReached = false

    var findPlansParameters: [String:AnyObject]?

    var plansEndPoint: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()
        let cellNib = UINib(nibName: "PlansCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: CellID.Plans.rawValue)
        
        if plansArray.count == 0 { //make sure data is not preloaded as in top collections case
            
            self.tableView.backgroundView = backgroundLabel
            self.tableView.backgroundView?.hidden = true

            getPlans()
        }
        

        
    }
    
    deinit {
        Plango.sharedInstance.userCache = [String : User]()
        Plango.sharedInstance.searchTotal = nil //because this persists across search instances be sure to clear it when search is dismissed
    }
    
    func clearTable() {
        plansArray.removeAll()
        tableView.reloadData()
    }
    
    //wrapper because depending on parent or instantiating controller, may need to call find plans or fetch plans, for example search vs my plans parents, this wrapper should be called which checks if there are parameters present and decides the correct fetch method that way
    func getPlans() {
        if Helper.isConnectedToNetwork() == false {
            guard plansArray.count == 0 else {return} //prevent realm query from replacing what user might have in RAM if app was already open when there was network connectivity
            
            let realm = try! Realm()
            let storedPlans = realm.objects(StoredPlan.self)
            var plans = [Plan]()
            for plan in storedPlans {
                plans.append(StoredPlan.unpackStoredPlan(plan))
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.plansArray = plans
                self.tableView.reloadData()
            })
            
        } else if fetchRequest == nil {
            if let parameters = findPlansParameters { //for search and categories
                findPlans(plansEndPoint, page: currentFetchPage + 1, parameters: parameters)
            } else if Plango.sharedInstance.currentUser != nil { //will come here on my plans page only, as categories and top collections have parameters or are preloaded
                fetchPlans(plansEndPoint)
            }
        }
    }
    
    private func fetchPlans(endPoint: String) {
        tableView.showSimpleLoading()
        fetchRequest = Plango.sharedInstance.fetchPlans(endPoint) {
            (receivedPlans: [Plan]?, error: PlangoError?) in
            self.tableView.hideSimpleLoading()
            self.fetchRequest = nil
            if let error = error {
                self.printPlangoError(error)
            } else if let plans = receivedPlans {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.plansArray = plans
                    if plans.count == 0 {
                        self.tableView.backgroundView?.hidden = false
                    }
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        checkAndAppendMorePlans()
    }
    
//    override func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
//        checkAndAppendMorePlans()
//    }
    
    func checkAndAppendMorePlans() {
        
        if findPlansParameters != nil { //check make sure supports pagination by seeing if parameters were set
            let lastRow = tableView.indexPathsForVisibleRows?.last?.row
            print("last row \(lastRow)")
            print("array count \(plansArray.count - 8)")
            
            if lastRow == plansArray.count - 8 && endReached == false {
                //request additional items as long as we are scrolled toward bottom and aren't already at the end of plango source
                getPlans()
            }
        }

        
    }
    
    private func findPlans(endPoint: String, page: Int, parameters: [String : AnyObject]) {
        self.tableView.showSimpleLoading()
        fetchRequest = Plango.sharedInstance.findPlans(endPoint, page: page, parameters: parameters) { (receivedPlans, error) in
            self.tableView.hideSimpleLoading()
            self.currentFetchPage = page
            self.fetchRequest = nil

            if let error = error {
                self.printPlangoError(error)
            } else if let plans = receivedPlans {
                if plans.count == 0 { //empty array means end of pagination
                    self.endReached = true
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
//                    if self.plansArray.count == 0 {
//                        self.plansArray = plans
//                    } else {
                        self.plansArray.appendContentsOf(plans)
//                    }
                    if self.plansArray.count == 0 {
                        self.tableView.backgroundView?.hidden = false
                    }
                    
                    if let total = Plango.sharedInstance.searchTotal {
                        if total == 1 {
                            self.navigationItem.title = "\(total) PLAN FOUND"
                        } else {
                            self.navigationItem.title = "\(total) PLANS FOUND"
                        }
                    }
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    // MARK: - Touch Gestures
    //not getting called, override in extension
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if let parent = parentViewController {
//            parent.view.endEditing(true)
//        }
//        self.view.endEditing(true)
//        self.tableView.endEditing(true)
//        super.touchesBegan(touches, withEvent: event)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if plansArray.count == 0 {
            return 0
        } else {
            tableView.backgroundView?.hidden = true
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plansArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellID.Plans.rawValue, forIndexPath: indexPath) as! PlansTableViewCell
        
        let plan = self.plansArray[indexPath.row]
        cell.plan = plan
        
        if findPlansParameters == nil && Plango.sharedInstance.currentUser != nil { //myplans
            cell.user = Plango.sharedInstance.currentUser!
        }
        
        cell.configure()
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Helper.CellHeight.plans.value //should be the same as xib file
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PlansTableViewCell
        let planSummary = PlanSummaryViewController()
        planSummary.plan = cell.plan
        planSummary.hidesBottomBarWhenPushed = true
        self.showViewController(planSummary, sender: nil)
    }
    
   // i guess not needed
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let report = UITableViewRowAction(style: .Destructive, title: "Report") { action, index in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                tableView.setEditing(false, animated: true)
                
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! PlansTableViewCell
                cell.contentView.showSimpleLoading()
                if let plan = cell.plan {
                    Plango.sharedInstance.reportSpam(Plango.EndPoint.Report.rawValue, planID: plan.id, onCompletion: { (error) in
                        cell.contentView.hideSimpleLoading()
                        if let error = error {
                            self.printPlangoError(error)
                            guard let message = error.message else {return}
                            cell.contentView.quickToast(message)
                        } else {
                            cell.contentView.imageToast("Successfully Sent", image: UIImage(named: "whiteCheck")!, notify: true)
                        }
                    })
                }
                
                //NOTE: - hide this for now, but would let user type in message saying why they object
//                let reportVC = UIStoryboard(name: StoryboardID.Main.rawValue, bundle: nil).instantiateViewControllerWithIdentifier(ViewControllerID.Report.rawValue) as! ReportViewController
//                reportVC.plan = cell.plan
//                self.showViewController(reportVC, sender: nil)
            })
        }
        return [report]
    }
}
