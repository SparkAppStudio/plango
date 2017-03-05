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


class PlansTableViewController: UITableViewController {
    
    //search criteria header
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var placesLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    
    var headerView: UIView!

    
    lazy var plansArray = [Plan]()
    
    //search criteria "\(parent.selectedTags?.description) in \(parent.selectedDestinations?.description) for \(parent.minDuration) - \(parent.maxDuration) days"
    
    lazy var backgroundLabel: UILabel = {
        let backgroundLabel = UILabel(frame: self.tableView.bounds)
        if self.findPlansParameters == nil { //nil means its MyPlans, not search
            backgroundLabel.text = "You have no plans.\nCreate a new one on the desktop at plango.us"
        } else {
            backgroundLabel.text = "0 results found"
        }
        backgroundLabel.numberOfLines = 0
        backgroundLabel.font = UIFont.plangoSectionHeader()
        backgroundLabel.textColor = UIColor.plangoTypeSectionHeaderGray()
        backgroundLabel.textAlignment = .center
        backgroundLabel.backgroundColor = UIColor.plangoBackgroundGray()
        return backgroundLabel
    }()
    
    var fetchRequest: Request?
    var currentFetchPage: Int = 0
    var endReached = false

    var findPlansParameters: [String:AnyObject]?
    var searchDestinations: [Destination]?

    var plansEndPoint: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()
        

        
        let cellNib = UINib(nibName: "PlansCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: CellID.Plans.rawValue)
        
        if plansArray.count == 0 { //make sure data is not preloaded as in top collections case
            
            self.tableView.backgroundView = backgroundLabel
            self.tableView.backgroundView?.isHidden = true

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
    
    func setupSearchResultsHeader() {
        let nib = UINib(nibName: "SearchResultsHeader", bundle: nil)
        headerView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        headerView.snp_makeConstraints { (make) in
            make.height.equalTo(Helper.HeaderHeight.section.value)
        }
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: Helper.HeaderHeight.section.value))
        
        containerView.addSubview(headerView)
        
        tableView.tableHeaderView = containerView
        
        headerView.leadingAnchor.constraint(equalTo: tableView.tableHeaderView!.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: tableView.tableHeaderView!.trailingAnchor).isActive = true
        headerView.bottomAnchor.constraint(equalTo: tableView.tableHeaderView!.bottomAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: tableView.tableHeaderView!.topAnchor).isActive = true
        
        tagsLabel.isHidden = true
        placesLabel.isHidden = true
        daysLabel.isHidden = true
    }
    
    func configureSearchResultsHeader(_ parameters: [String : AnyObject]) {
        tagsLabel.isHidden = false
        placesLabel.isHidden = false
        daysLabel.isHidden = false
        if let tags = parameters["tags"] as? String {
            tagsLabel.text = tags
        }
        if parameters["selectedPlaces"] != nil {
            if let destinations = searchDestinations {
                var text = "in "
                for place in destinations {
                    if let city = place.city {
                        text = text + "\(city), "
                    } else if let state = place.state {
                        if let fullState = state.getLongState() {
                            text = text + "\(fullState.capitalized), "
                        } else {
                            text = text + "\(state.capitalized), "
                        }
                    } else if let country = place.country {
                        text = text + "\(country), "
                    }
                }
                if text == "in " {
                    placesLabel.text = ""
                } else {
                    placesLabel.text = String(text.characters.dropLast(2))
                }
                
            }
        } else {
            placesLabel.text = ""
        }

        if let durationFrom = parameters["durationFrom"] as? String {
            daysLabel.text = "from \(durationFrom)"
        } else {
            daysLabel.text = "from 1"
        }
        if let durationTo = parameters["durationTo"] as? String {
            daysLabel.text = daysLabel.text! + " - \(durationTo) days"
        } else {
            daysLabel.text = daysLabel.text! + " - Many days"
        }
        if daysLabel.text == "from 1 - Many days" {
            daysLabel.text = ""
        }
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
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.plansArray = plans
                self.tableView.reloadData()
            })
            
        } else if fetchRequest == nil {
            if let parameters = findPlansParameters { //for search and categories
                setupSearchResultsHeader()
                findPlans(plansEndPoint, page: currentFetchPage + 1, parameters: parameters)
            } else if Plango.sharedInstance.currentUser != nil { //will come here on my plans page only, as categories and top collections have parameters or are preloaded
                fetchPlans(plansEndPoint)
            }
        }
    }
    
    fileprivate func fetchPlans(_ endPoint: String) {
        tableView.showSimpleLoading()
        fetchRequest = Plango.sharedInstance.fetchPlans(endPoint) {
            (receivedPlans: [Plan]?, error: PlangoError?) in
            self.tableView.hideSimpleLoading()
            self.fetchRequest = nil
            if let error = error {
                self.printPlangoError(error)
            } else if let plans = receivedPlans {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.plansArray = plans
                    if plans.count == 0 {
                        self.tableView.backgroundView?.isHidden = false
                    }
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    
    fileprivate func findPlans(_ endPoint: String, page: Int, parameters: [String : AnyObject]) {
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
                DispatchQueue.main.async(execute: { () -> Void in
                    
//                    if self.plansArray.count == 0 {
//                        self.plansArray = plans
//                    } else {
                        self.plansArray.append(contentsOf: plans)
//                    }
                    if self.plansArray.count == 0 {
                        self.tableView.backgroundView?.isHidden = false
                    }
                    
                    if let total = Plango.sharedInstance.searchTotal {
                        self.configureSearchResultsHeader(parameters)
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        if plansArray.count == 0 {
            return 0
        } else {
            tableView.backgroundView?.isHidden = true
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plansArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID.Plans.rawValue, for: indexPath) as! PlansTableViewCell
        
        let plan = self.plansArray[indexPath.row]
        cell.plan = plan
        
        if findPlansParameters == nil && Plango.sharedInstance.currentUser != nil && self.navigationController?.viewControllers.count < 2 { //myplans, if nav has more than 2 its plangoCollections
            cell.user = Plango.sharedInstance.currentUser!
        }
        
        cell.configure()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Helper.CellHeight.plans.value //should be the same as xib file
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PlansTableViewCell
        let planSummary = PlanSummaryViewController()
        planSummary.plan = cell.plan
        planSummary.hidesBottomBarWhenPushed = true
        self.show(planSummary, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if findPlansParameters != nil {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let report = UITableViewRowAction(style: UITableViewRowActionStyle(), title: "Report") { action, index in
            DispatchQueue.main.async(execute: { () -> Void in
                tableView.setEditing(false, animated: true)
                
                let cell = tableView.cellForRow(at: indexPath) as! PlansTableViewCell
                cell.contentView.showSimpleLoading()
                if let plan = cell.plan {
                    Plango.sharedInstance.reportSpam(Plango.EndPoint.Report.value, planID: plan.id, onCompletion: { (error) in
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
