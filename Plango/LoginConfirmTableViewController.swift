//
//  LoginConfirmTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 6/8/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginConfirmTableViewController: UITableViewController, UITextFieldDelegate {

    lazy var usernameTextField: UITextField = {
        let text = UITextField()
        text.borderStyle = .None
        text.placeholder = "Username"
        text.keyboardType = .Default
        text.autocorrectionType = .No
        text.autocapitalizationType = .None
        text.delegate = self
        return text
    }()
    
    lazy var emailTextField: UITextField = {
        let text = UITextField()
        text.borderStyle = .None
        text.placeholder = "Email Address"
        text.keyboardType = .EmailAddress
        text.autocorrectionType = .No
        text.autocapitalizationType = .None
        text.delegate = self
        return text
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.plangoOrange()
        button.tintColor = UIColor.whiteColor()
        button.setTitle("Signup", forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(didTapLogin), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var footerView: UIView = {
        let view = UIView()
        return view
    }()
    
    var facebookResult: FBSDKLoginManagerLoginResult!
    var facebookUserID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserverForName(Notify.Timer.rawValue, object: nil, queue: nil) { (notification) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
                //should be handled by coverLoginVC which is root of this hierarchy
//                let app = UIApplication.sharedApplication().delegate as! AppDelegate
//                app.swapLoginControllerInTab()

            })
        }
        
        footerView.addSubview(loginButton)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "username")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "email")
        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()

        
        let parameters = ["fields":"id, name, email"]
        FBSDKGraphRequest.init(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connection, result, error) in
            if let error = error {
                self.printError(error)
            } else {
                let email = result.valueForKey("email") as! String
                self.facebookUserID = result.valueForKey("id") as! String
                
                self.emailTextField.text = email
                
            }
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        loginButton.heightAnchor.constraintEqualToConstant(50).active = true
//        loginButton.widthAnchor.constraintEqualToConstant(self.view.frame.width - 16).active = true
        loginButton.frame = CGRect(x: 8, y: 8, width: self.view.frame.width - 16, height: 50)

        loginButton.makeRoundCorners(90)
    }
    
    func didTapLogin(button: UIButton) {

        guard let userEmail = emailTextField.text else {
            self.tableView.quickToast("Please Enter a Email")
            return
        }

        guard let userName = usernameTextField.text else {
            self.tableView.quickToast("We Need a Username")
            return
        }
        
        guard let userID = facebookUserID else {return}
            
        if userEmail.isEmpty {
            self.tableView.quickToast("Please Enter your Email")
        } else if userName.isEmpty {
            self.tableView.quickToast("We Need a Username")
        } else {
            guard let result = facebookResult else {return}
            NSNotificationCenter.defaultCenter().postNotificationName(Notify.NewUser.rawValue, object: nil, userInfo: ["controller" : self, "FBSDKLoginResult" : result, "userEmail" : userEmail, "userName" : userName, "userID" : userID])
        }
    }
    

    // MARK: - Text Field
    
    func processTextField(textField: UITextField) {
        textField.text?.trimWhiteSpace()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        textField.layer.borderWidth = 0.0
        
        processTextField(textField)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        //enable tab
        if string == "\t" {
            textField.endEditing(true)
            return false
        }
        
        switch textField {
        case usernameTextField:
            // method checks and sanitizes text for search
            if let textErrors = Helper.isValidUserNameWithErrors(textField.text, possibleNewCharacter: string) {
                self.view.quickToast(textErrors)
                return false
            } else {
                // textErrors = nil so NO ERRORS proceed with text
                
                return true
            }
            
        case emailTextField:
            // method checks and sanitizes text for search
            if let textErrors = Helper.isValidEmailWithErrors(textField.text, possibleNewCharacter: string) {
                self.view.quickToast(textErrors)
                return false
            } else {
                // textErrors = nil so NO ERRORS proceed with text
                
                return true
            }
            
        default:
            return true
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 64
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("username", forIndexPath: indexPath)
            usernameTextField.frame = CGRectMake(8, 4, cell.contentView.frame.width - 16, cell.contentView.frame.height - 8)
            cell.contentView.addSubview(usernameTextField)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("email", forIndexPath: indexPath)
            emailTextField.frame = CGRectMake(8, 4, cell.contentView.frame.width - 16, cell.contentView.frame.height - 8)
            cell.contentView.addSubview(emailTextField)
            return cell
        }
    }
}
