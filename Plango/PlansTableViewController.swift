//
//  PlanListTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import SwiftyJSON

class PlansTableViewController: UITableViewController {
    
    lazy var usersDictionary = [NSIndexPath:User]()
    lazy var plansArray = [Plan]()
    
    var plansEndPoint: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.plangoCream()
        let cellNib = UINib(nibName: "PlansCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: CellID.Plans.rawValue)
        
        fetchPlans(plansEndPoint)
    }
    
    func fetchUserForPlan(endPoint: String, indexPath: NSIndexPath) {
        Plango.sharedInstance.fetchUsers(endPoint) {
            (receivedUsers: [User]?, error: NSError?) in
            if let error = error {
                print(error.description)
            } else if let users = receivedUsers {
                self.usersDictionary[indexPath] = users.first!
                //TODO: - update tableView
                let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! PlansTableViewCell
                cell.user = users.first!
                print("\(cell.user?.displayName) has \(cell.user?.invites?.description) invites")
                cell.configure()
//                self.tableView.reloadData()
            }
        }
    }
    
    func fetchPlans(endPoint: String) {
//        Plango.sharedInstance.fetchPlans(endPoint) {
//            (receivedPlans: [Plan]?, error: NSError?) in
//            if let error = error {
//                print(error.description)
//            } else if let plans = receivedPlans {
//                self.plansArray = plans
//                self.tableView.reloadData()
//                for plan in plans {
//                    self.fetchUsers("\(Plango.EndPoint.UserByID.rawValue)\(plan.authorID)")
//                }
//            }
//        }
        
        //test implementation
        guard let urlEndPoint = NSBundle.mainBundle().URLForResource("test", withExtension: "json") else {
            return
        }

        let testData = try! NSData(contentsOfURL: urlEndPoint, options: .DataReadingMappedIfSafe)
        
        let testJSON = JSON(data: testData)
        
        self.plansArray = Plan.getPlansFromJSON(testJSON)
        self.tableView.reloadData()
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plansArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellID.Plans.rawValue, forIndexPath: indexPath) as! PlansTableViewCell
        
        let plan = self.plansArray[indexPath.row]
        print("the plan duration is \(plan.durationDays?.description)")
        cell.plan = plan
        self.fetchUserForPlan("\(Plango.EndPoint.UserByID.rawValue)\(plan.authorID)", indexPath: indexPath)

        
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
        self.showViewController(planSummary, sender: nil)
    }
    

}
