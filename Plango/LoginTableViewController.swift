//
//  LoginTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginTableViewController: UITableViewController, UITextFieldDelegate {
    
    var loginSegment: UISegmentedControl!
    
    lazy var cancelBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "CANCEL", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(didTapCancel))
        return button
    }()
    
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
    
//    lazy var userOrEmailTextField: UITextField = {
//        let text = UITextField()
//        text.borderStyle = .None
//        text.placeholder = "Username or Email"
//        text.keyboardType = .EmailAddress
//        text.autocorrectionType = .No
//        text.autocapitalizationType = .None
//        text.delegate = self
//        return text
//    }()
    
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
    
    lazy var passwordTextField: UITextField = {
        let text = UITextField()
        text.borderStyle = .None
        text.placeholder = "Password"
        text.secureTextEntry = true
        text.autocorrectionType = .No
        text.autocapitalizationType = .None
        text.delegate = self
        return text
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.plangoOrange()
        button.tintColor = UIColor.whiteColor()
        button.setTitle("Log in", forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(didTapLogin), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var footerView: UIView = {
       let view = UIView()
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .Vertical
        return view
    }()
    
    lazy var facebookButton: FBSDKLoginButton = {
       let button = FBSDKLoginButton()
        button.delegate = self
        button.readPermissions = ["public_profile", "email", "user_friends"]
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName(Notify.Timer.rawValue, object: nil, queue: nil) { (notification) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                //TODO: - try changing the root controller instead of dismissing
            })
        }
        
        facebookButton.titleLabel?.font = loginButton.titleLabel?.font
        
        
        stackView.spacing = 8
        stackView.distribution = .EqualSpacing
        stackView.alignment = .Center
//        stackView.layoutMargins.left = 16
//        stackView.layoutMargins.right = 16
        
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(facebookButton)

        footerView.addSubview(stackView)
        
        let titles = ["Login", "Signup"]
        loginSegment = UISegmentedControl(items: titles)
        loginSegment.selectedSegmentIndex = 0
        loginSegment.addTarget(self, action: #selector(LoginTableViewController.didChangeLoginSegment), forControlEvents: .ValueChanged)
        loginSegment.sizeToFit()
        navigationItem.titleView = loginSegment
        navigationItem.leftBarButtonItem = cancelBarButton
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "username")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "usernameemail")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "email")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "password")
        
        
        
        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        stackView.leadingAnchor.constraintEqualToAnchor(footerView.leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(footerView.trailingAnchor).active = true
        stackView.bottomAnchor.constraintEqualToAnchor(footerView.bottomAnchor).active = true
        stackView.topAnchor.constraintEqualToAnchor(footerView.topAnchor).active = true
        
        loginButton.heightAnchor.constraintEqualToConstant(50).active = true
        loginButton.widthAnchor.constraintEqualToConstant(self.view.frame.width - 16).active = true
        loginButton.makeRoundCorners(90)
        facebookButton.heightAnchor.constraintEqualToAnchor(loginButton.heightAnchor).active = true
        facebookButton.widthAnchor.constraintEqualToAnchor(loginButton.widthAnchor).active = true
    }
    
    func didTapCancel() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didChangeLoginSegment() {
        if loginSegment.selectedSegmentIndex == 0 {
            loginButton.setTitle("Log in", forState: .Normal)
            facebookButton.setAttributedTitle(NSAttributedString(string: "Log in with Facebook"), forState: .Normal)
        } else {
            loginButton.setTitle("Sign up", forState: .Normal)
            facebookButton.setAttributedTitle(NSAttributedString(string: "Sign up with Facebook"), forState: .Normal)

        }
        tableView.reloadData()
    }

    // doesnt work because need to override the tableView touches began, not the controller touches began, but then that will break ability to select cells
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesBegan(touches, withEvent: event)
//        self.tableView.endEditing(true)
//    }
    
    func didTapLogin(button: UIButton) {
        if loginSegment.selectedSegmentIndex == 0 {
            guard let userEmail = emailTextField.text else {
                self.tableView.quickToast("Please Enter your Email")
                return
            }
            guard let password = passwordTextField.text else {
                self.tableView.quickToast("Please Enter your Password")
                return
            }
            
            if userEmail.isEmpty {
                self.tableView.quickToast("Please Enter your Email")
            } else if password.isEmpty {
                self.tableView.quickToast("Please Enter your Password")
            } else {
                let userInfo = ["controller" : self, "userEmail" : userEmail, "password" : password]
                NSNotificationCenter.defaultCenter().postNotificationName(Notify.Login.rawValue, object: nil, userInfo: userInfo)
            }
            
        } else {
            guard let userEmail = emailTextField.text else {
                self.tableView.quickToast("Please Enter a Email")
                return
            }
            guard let password = passwordTextField.text else {
                self.tableView.quickToast("Please Enter a Password")
                return
            }
            guard let userName = usernameTextField.text else {
                self.tableView.quickToast("We Need a Username")
                return
            }
            
            if userEmail.isEmpty {
                self.tableView.quickToast("Please Enter your Email")
            } else if password.isEmpty {
                self.tableView.quickToast("Please Enter your Password")
            } else if userName.isEmpty {
                self.tableView.quickToast("We Need a Username")
            } else {
                let userInfo = ["controller" : self, "userEmail" : userEmail, "password" : password, "userName" : userName]
                NSNotificationCenter.defaultCenter().postNotificationName(Notify.NewUser.rawValue, object: nil, userInfo: userInfo)
            }

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
            // method checks and sanitizes text for search
            if let textErrors = Helper.isValidPasswordWithErrors(textField.text, possibleNewCharacter: string) {
                self.view.quickToast(textErrors)
                return false
            } else {
                // textErrors = nil so NO ERRORS proceed with text
                
                return true
            }

        }
        
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loginSegment.selectedSegmentIndex == 0 {
            return 2
        } else {
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 108
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
//    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        let textFrame = CGRectMake(8, 4, cell.contentView.frame.width - 16, cell.contentView.frame.height - 8)
//        usernameTextField.frame = textFrame
//        userOrEmailTextField.frame = textFrame
//        emailTextField.frame = textFrame
//        passwordTextField.frame = textFrame
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if loginSegment.selectedSegmentIndex == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("email", forIndexPath: indexPath)
                emailTextField.frame = CGRectMake(8, 4, cell.contentView.frame.width - 16, cell.contentView.frame.height - 8)
                cell.contentView.addSubview(emailTextField)
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("password", forIndexPath: indexPath)
                passwordTextField.frame = CGRectMake(8, 4, cell.contentView.frame.width - 16, cell.contentView.frame.height - 8)
                cell.contentView.addSubview(passwordTextField)
                return cell
            }
        } else {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("username", forIndexPath: indexPath)
                usernameTextField.frame = CGRectMake(8, 4, cell.contentView.frame.width - 16, cell.contentView.frame.height - 8)
                cell.contentView.addSubview(usernameTextField)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("email", forIndexPath: indexPath)
                emailTextField.frame = CGRectMake(8, 4, cell.contentView.frame.width - 16, cell.contentView.frame.height - 8)
                cell.contentView.addSubview(emailTextField)
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("password", forIndexPath: indexPath)
                passwordTextField.frame = CGRectMake(8, 4, cell.contentView.frame.width - 16, cell.contentView.frame.height - 8)
                cell.contentView.addSubview(passwordTextField)
                return cell
            }
        }
        

    }
}

extension LoginTableViewController: FBSDKLoginButtonDelegate {
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            printError(error)
            self.tableView.quickToast(error.localizedFailureReason!)
        } else if result.isCancelled == false {
            let confirmVC = LoginConfirmTableViewController()
            confirmVC.facebookResult = result
            if loginSegment.selectedSegmentIndex == 0 {
                NSNotificationCenter.defaultCenter().postNotificationName(Notify.Login.rawValue, object: nil, userInfo: ["controller" : self, "FBSDKLoginResult":result])
            } else {
                self.showViewController(confirmVC, sender: nil)
            }
        } else {
            //user cancelled fb login
        }

    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        NSNotificationCenter.defaultCenter().postNotificationName(Notify.Logout.rawValue, object: nil, userInfo: ["controller" : self])
    }
}
