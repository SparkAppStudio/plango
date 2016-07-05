//
//  PlanMembersTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 6/30/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class PlanMembersTableViewController: UITableViewController {

    var members: [Member]!
    
    private var confirmedUsers = [User]()
    private var unconfirmedUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()
        
        let cellNib = UINib(nibName: "MemberCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: CellID.Member.rawValue)


        getMembers()
    }

    func getMembers() {
            //get rid of self
            for (index, member) in members.enumerate() {
                if member.userID == Plango.sharedInstance.currentUser?.id {
                    members.removeAtIndex(index)
                }
            }
            
            //divide up confirmed and unconfirmed
            var confirmedMembers = [Member]()
            var unconfirmedMembers = [Member]()
            
            for member in members {
                if member.confirmed == true {
                    confirmedMembers.append(member)
                } else {
                    unconfirmedMembers.append(member)
                }
            }
            
        Plango.sharedInstance.fetchMembersFromPlan(Plango.EndPoint.Members.rawValue, members: confirmedMembers) { (users, error) in
            if let error = error {
                self.printPlangoError(error)
            } else if let users = users {
                self.confirmedUsers = users
                self.tableView.reloadData()
            }
        }
        Plango.sharedInstance.fetchMembersFromPlan(Plango.EndPoint.Members.rawValue, members: unconfirmedMembers) { (users, error) in
            if let error = error {
                self.printPlangoError(error)
            } else if let users = users {
                self.unconfirmedUsers = users
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return unconfirmedUsers.count
        default:
            return confirmedUsers.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellID.Member.rawValue, forIndexPath: indexPath) as! MemberTableViewCell

        switch indexPath.section {
        case 0:
            cell.user = unconfirmedUsers[indexPath.row]
            cell.configure()
        default:
            cell.user = confirmedUsers[indexPath.row]
            cell.configure()
        }

        return cell
    }

}
