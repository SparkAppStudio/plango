//
//  LoginTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class LoginTableViewController: UITableViewController, UITextFieldDelegate {
    

    
    var loginSegment: UISegmentedControl!
    
    var textToSend: String!
    var passwordToSend: String!

    
    lazy var usernameTextField: UITextField = {
        let text = UITextField()
        text.borderStyle = .None
        text.placeholder = "Username"
        text.delegate = self
        return text
    }()
    
    lazy var userOrEmailTextField: UITextField = {
        let text = UITextField()
        text.borderStyle = .None
        text.placeholder = "Username or Email Address"
        text.delegate = self
        return text
    }()
    
    lazy var emailTextField: UITextField = {
        let text = UITextField()
        text.borderStyle = .None
        text.placeholder = "Email Address"
        text.delegate = self
        return text
    }()
    
    lazy var passwordTextField: UITextField = {
        let text = UITextField()
        text.borderStyle = .None
        text.placeholder = "Password"
        text.delegate = self
        return text
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.frame = CGRectMake(8, 8, self.tableView.frame.width - 16, 30)
        button.backgroundColor = UIColor.plangoOrange()
        button.tintColor = UIColor.whiteColor()
        button.setTitle("Log In", forState: UIControlState.Normal)
        button.makeRoundCorners(64)
        button.addTarget(self, action: #selector(didTapLogin), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var footerView: UIView = {
       let view = UIView()
        return view
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        footerView.addSubview(loginButton)
        
        let titles = ["Login", "Signup"]
        loginSegment = UISegmentedControl(items: titles)
        loginSegment.selectedSegmentIndex = 0
        loginSegment.addTarget(self, action: #selector(LoginTableViewController.didChangeLoginSegment), forControlEvents: .ValueChanged)
        loginSegment.sizeToFit()
        navigationItem.titleView = loginSegment
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "username")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "usernameemail")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "email")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "password")
        
        
        
        self.tableView.backgroundColor = UIColor.plangoCream()

    }
    
    func didChangeLoginSegment() {
        tableView.reloadData()
    }
    
    func didTapLogin(button: UIButton) {
        login()
    }
    
    func login() {
        Plango.sharedInstance.loginUserWithPassword(Plango.EndPoint.Login.rawValue, email: textToSend, password: passwordToSend) { (user, error) in
            if let error = error {
                print(Helper.printErrorMessage(self, error: error))
    
            } else {
                Plango.sharedInstance.currentUser = user
                print(Plango.sharedInstance.currentUser?.userName)
            }
        }
    }

    
    // MARK: - Text Field
    
    func processTextField(textField: UITextField) {
        
        switch textField {
        case self.usernameTextField:
            textToSend = textField.text
        case self.passwordTextField:
            passwordToSend = textField.text
        default:
            break
        }
        
        
        //        if let text = textField.text {
        //            if text.characters.count > 0 {
        //                if let currentProfile = self.profile {
        //                    if let handle = currentProfile.handle {
        //                        if handle != text {
        //                            RVFirebaseUserProfile.lookUpProfileViaHandle(text, callback: { (error, userProfiles) -> Void in
        //                                if let error = error {
        //                                    error.printError("\(self.classForCoder)", method: "processTextField", message: nil)
        //
        //                                } else if userProfiles.count == 0 {
        //                                    currentProfile.handle = text
        //                                    currentProfile.save({ (error, ref) -> (Void) in
        //                                        self.view.quickToast("updated name")
        //                                    })
        //                                } else if userProfiles.count >= 1 {
        //                                    self.view.quickToast("sorry name already taken")
        //
        //                                }
        //                            })
        //                        }
        //                    }
        //                } else {
        //                    print("In \(self.classForCoder).processTextField, no userProfile")
        //                }
        //
        //
        //            }
        //        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        switch textField {
        case self.usernameTextField:
            textToSend = textField.text
        case self.passwordTextField:
            passwordToSend = textField.text
        default:
            break
        }
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
        
        // method checks and sanitizes text for search
        if let textErrors = Helper.isValidSearchWithErrors(textField.text, possibleNewCharacter: string) {
            self.view.quickToast(textErrors)
            Helper.textIsValid(textField, sender: false)
            return false
        } else {
            // textErrors = nil so NO ERRORS proceed with text
            Helper.textIsValid(textField, sender: true)
            switch textField {
            case self.usernameTextField:
                textToSend = textField.text
            case self.passwordTextField:
                passwordToSend = textField.text
            default:
                break
            }
            return true
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
        return 60
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
                let cell = tableView.dequeueReusableCellWithIdentifier("usernameemail", forIndexPath: indexPath)
                usernameTextField.frame = CGRectMake(8, 4, cell.contentView.frame.width - 16, cell.contentView.frame.height - 8)
                cell.contentView.addSubview(usernameTextField)
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
