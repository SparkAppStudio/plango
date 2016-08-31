//
//  LoginConfirmViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 6/8/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginConfirmViewController: LoginViewController {

//    lazy var usernameTextField: UITextField = {
//        let text = UITextField()
//        text.borderStyle = .None
//        text.placeholder = "Username"
//        text.keyboardType = .Default
//        text.autocorrectionType = .No
//        text.autocapitalizationType = .None
//        text.delegate = self
//        return text
//    }()
//    
//    lazy var emailTextField: UITextField = {
//        let text = UITextField()
//        text.borderStyle = .None
//        text.placeholder = "Email Address"
//        text.keyboardType = .EmailAddress
//        text.autocorrectionType = .No
//        text.autocapitalizationType = .None
//        text.delegate = self
//        return text
//    }()
//    
//    lazy var signupButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = UIColor.transparentGray()
//        button.layer.borderColor = UIColor.whiteColor().CGColor
//        button.layer.borderWidth = 3
//        button.tintColor = UIColor.whiteColor()
//        button.setTitle("SIGN UP", forState: UIControlState.Normal)
//        button.titleLabel?.font = UIFont.plangoButton()
//        button.addTarget(self, action: #selector(didTapLogin), forControlEvents: .TouchUpInside)
//        return button
//    }()
    
//    lazy var footerView: UIView = {
//        let view = UIView()
//        return view
//    }()
    
    var facebookResult: FBSDKLoginManagerLoginResult!
    var facebookUserID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        NSNotificationCenter.defaultCenter().addObserverForName(Notify.Timer.rawValue, object: nil, queue: nil) { (notification) in
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                
//                self.dismissViewControllerAnimated(true, completion: nil)
//
//            })
//        }
        
        //remove unnecessary stuff that was set in superclass
        headerStackView.removeFromSuperview()
        footerStackView.removeFromSuperview()
        
        footerView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 66)
        loginButton.setTitle("SIGN UP", forState: .Normal)
        footerView.addSubview(loginButton)
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "username")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "email")
        
        let parameters = ["fields":"id, name, email"]
        FBSDKGraphRequest.init(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connection, result, error) in
            if let error = error {
                self.printError(error)
            } else {
                let email = result.valueForKey("email") as! String
                self.facebookUserID = result.valueForKey("id") as! String
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.emailTextField.text = email
                })

            }
        })
    }

    override func viewDidLayoutSubviews() {
        //dont call super, views have been removed in this subclass and trying to set constraints will make it crash
//        super.viewDidLayoutSubviews()
        
        loginButton.fitLoginButtons(self)
        loginButton.snp_makeConstraints { (make) in
            make.center.equalTo(footerView)
        }
    }
    
    override func didTapLogin(button: UIButton) {

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
            NSNotificationCenter.defaultCenter().postNotificationName(Notify.NewUser.rawValue, object: nil, userInfo: ["controller" : self, "FBSDKLoginResult" : result, "userEmail" : userEmail.lowercaseString, "userName" : userName, "userID" : userID])
        }
    }
    
    override func didTapCancel() {
        super.didTapCancel()
        FBSDKLoginManager().logOut() //In this case we cannot logout of facebook soley relying on error in the appdelegate handlePlangoAuth method because user may correct mistake like "username in use" and then will need facebook credentials. So, only log out of facebook if they tap cancel, which takes the user all the way back to main loginCoverVC where they would need to tap facebook button again.
    }
    

    // MARK: - Text Field
    
//    func processTextField(textField: UITextField) {
//        textField.text?.trimWhiteSpace()
//    }
//    
//    func textFieldDidBeginEditing(textField: UITextField) {
//        
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.endEditing(true)
//        return true
//    }
//    
//    func textFieldShouldClear(textField: UITextField) -> Bool {
//        return true
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField) {
//        textField.resignFirstResponder()
//        textField.layer.borderWidth = 0.0
//        
//        processTextField(textField)
//    }
//    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        
//        //enable tab
//        if string == "\t" {
//            textField.endEditing(true)
//            return false
//        }
//        
//        switch textField {
//        case usernameTextField:
//            // method checks and sanitizes text for search
//            if let textErrors = Helper.isValidUserNameWithErrors(textField.text, possibleNewCharacter: string) {
//                self.view.quickToast(textErrors)
//                return false
//            } else {
//                // textErrors = nil so NO ERRORS proceed with text
//                
//                return true
//            }
//            
//        case emailTextField:
//            // method checks and sanitizes text for search
//            if let textErrors = Helper.isValidEmailWithErrors(textField.text, possibleNewCharacter: string) {
//                self.view.quickToast(textErrors)
//                return false
//            } else {
//                // textErrors = nil so NO ERRORS proceed with text
//                
//                return true
//            }
//            
//        default:
//            return true
//        }
//    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("username", forIndexPath: indexPath)
            usernameTextField.frame = cellFrame(cell)
            cell.contentView.addSubview(usernameTextField)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("email", forIndexPath: indexPath)
            emailTextField.frame = cellFrame(cell)
            cell.contentView.addSubview(emailTextField)
            return cell
        }
    }
}
