//
//  SideMenuTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    lazy var accountBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "LOGOUT", style: .plain, target: self, action: #selector(didTapAccountButton))
        return button
    }()
    
    @objc func didTapAccountButton() {
        if Plango.sharedInstance.currentUser == nil {
            self.navigationController?.present(LoginViewController(), animated: true, completion: nil)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Notify.Logout.rawValue), object: nil, userInfo: ["controller": self])
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = accountBarButton

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "test")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        checkForCurrentUserCookies()
        if Plango.sharedInstance.currentUser == nil {
            accountBarButton.title = "LOGIN"
        } else {
            accountBarButton.title = "LOGOUT"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkForCurrentUserCookies() {
        print(Plango.sharedInstance.currentUser?.userName ?? "no user found")

        guard let storage = Plango.sharedInstance.alamoManager.session.configuration.httpCookieStorage else {return}
        if let cookies = storage.cookies {
            print("Cookies Count: \(cookies.count)")
            for aCookie in cookies {
                print(aCookie.description)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "test", for: indexPath)
        cell.textLabel?.text = "Hello"
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
