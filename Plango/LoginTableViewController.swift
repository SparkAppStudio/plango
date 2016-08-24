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
    
    enum Heights: Int {
        case FooterLogin
        case FooterSignup
        case Header
        var value: CGFloat {
            switch self {
            case .FooterLogin: return 130 //loginButton(50) + forgotButton (24) + toggleButton (24) + spacing (8x2) + topMargin (16)
            case .FooterSignup: return 98 //loginButton(50) + toggleButton (24) + spacing (8) + topMargin (16)
            case .Header: return 114 //facebookButton(50) + orLabel (24) + spacing (8) + top and bottom Margins (32)
            }
        }
    }
    
//    var headerView: UIView!
//    let blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
    
    lazy var cancelBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "CANCEL", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(didTapCancel))
        return button
    }()
    
    lazy var usernameTextField: UITextField = {
        let text = UITextField()
        text.borderStyle = .None
        text.placeholder = "Username"
        text.font = UIFont.plangoBodyBig()
        text.textColor = UIColor.plangoTextLight()
        text.keyboardType = .ASCIICapable
        text.returnKeyType = .Next
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
        text.font = UIFont.plangoBodyBig()
        text.textColor = UIColor.plangoTextLight()
        text.keyboardType = .EmailAddress
        text.returnKeyType = .Next
        text.autocorrectionType = .No
        text.autocapitalizationType = .None
        text.delegate = self
        return text
    }()
    
    lazy var passwordTextField: UITextField = {
        let text = UITextField()
        text.borderStyle = .None
        text.placeholder = "Password"
        text.font = UIFont.plangoBodyBig()
        text.textColor = UIColor.plangoTextLight()
        text.secureTextEntry = true
        text.returnKeyType = .Go
        text.autocorrectionType = .No
        text.autocapitalizationType = .None
        text.delegate = self
        return text
    }()
    
    var loginSegment: UISegmentedControl! //i use this to manage the state but not the UI element
    lazy var toggleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clearColor()
        button.tintColor = UIColor.whiteColor()
        button.setTitle("Don't have an account? Sign Up!", forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(didTapToggle), forControlEvents: .TouchUpInside)
        button.titleLabel?.font = UIFont.plangoSmallButton()
        
        return button
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.transparentGray()
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 3
        button.tintColor = UIColor.whiteColor()
        button.setTitle("LOG IN", forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.plangoButton()
        button.addTarget(self, action: #selector(didTapLogin), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var footerView: UIView = {
       let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: Heights.FooterLogin.value))
        return view
    }()
    
    lazy var containerHeaderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: Heights.Header.value))
        return view
    }()

    lazy var orLabel: UILabel = {
        let label = UILabel()
        label.text = "OR"
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.plangoButton()
        return label
    }()
    
    lazy var headerStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .Vertical
        view.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        view.layoutMarginsRelativeArrangement = true
        view.spacing = 8
        view.distribution = .EqualSpacing
        view.alignment = .Center
        return view
    }()
    
    lazy var footerStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .Vertical
        view.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        view.layoutMarginsRelativeArrangement = true
        view.spacing = 8
        view.distribution = .EqualSpacing
        view.alignment = .Center
        return view
    }()
    
    lazy var facebookButton: FBSDKLoginButton = {
       let button = FBSDKLoginButton()
        button.delegate = self
        button.readPermissions = ["public_profile", "email", "user_friends"]
        button.setAttributedTitle(NSAttributedString(string: "Log in with Facebook".uppercaseString), forState: .Normal)
        button.titleLabel?.font = UIFont.plangoButton()
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 3

        return button
    }()
    
    lazy var forgotPasswordButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = UIColor.clearColor()
        button.tintColor = UIColor.whiteColor()
        button.setTitle("Forgot Password?", forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(didTapForgotPassword), forControlEvents: .TouchUpInside)
        button.titleLabel?.font = UIFont.plangoSmallButton()
        return button

    }()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
        //lazy instantiaion wasnt working for some reason
        let titles = ["LOG IN", "SIGN UP"]
        loginSegment = UISegmentedControl(items: titles)
        loginSegment.selectedSegmentIndex = 0
        loginSegment.addTarget(self, action: #selector(LoginTableViewController.didChangeLoginSegment), forControlEvents: .ValueChanged)
        loginSegment.sizeToFit()
        loginSegment.tintColor = UIColor.whiteColor()
//        navigationItem.titleView = loginSegment

        
        NSNotificationCenter.defaultCenter().addObserverForName(Notify.Timer.rawValue, object: nil, queue: nil) { (notification) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                
                let app = UIApplication.sharedApplication().delegate as! AppDelegate
                app.swapLoginControllerInTab()

            })
        }
        
        //tableHeader view with xib
//        let bundle = NSBundle(forClass: self.dynamicType)
//
//        let nib = UINib(nibName: "LoginHeader", bundle: bundle)
//        headerView = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
//        headerView.snp_makeConstraints { (make) in
//            make.height.equalTo(Helper.CellHeight.superWide.value-30)
//        }
        
//        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: Helper.CellHeight.superWide.value-30))
//        
//        containerView.addSubview(headerView)
//        tableView.tableHeaderView = containerView

//        headerView.leadingAnchor.constraintEqualToAnchor(tableView.tableHeaderView!.leadingAnchor).active = true
//        headerView.trailingAnchor.constraintEqualToAnchor(tableView.tableHeaderView!.trailingAnchor).active = true
//        headerView.bottomAnchor.constraintEqualToAnchor(tableView.tableHeaderView!.bottomAnchor).active = true
//        headerView.topAnchor.constraintEqualToAnchor(tableView.tableHeaderView!.topAnchor).active = true
        
        //footer
        footerStackView.addArrangedSubview(loginButton)
        footerStackView.addArrangedSubview(forgotPasswordButton)
        footerStackView.addArrangedSubview(toggleButton)

        footerView.addSubview(footerStackView)
        tableView.tableFooterView = footerView
        
        //header
        headerStackView.addArrangedSubview(facebookButton)
        headerStackView.addArrangedSubview(orLabel)
        
        containerHeaderView.addSubview(headerStackView)
        tableView.tableHeaderView = containerHeaderView
        

        
        
//        navigationItem.leftBarButtonItem = cancelBarButton not needed when swapping rootVCs
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "username")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "usernameemail")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "email")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "password")
        
        
        
//        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()
        let backgroundImageView = UIImageView(frame: tableView.frame)
        backgroundImageView.image = UIImage(named: "login-bg")
        backgroundImageView.contentMode = .ScaleAspectFill
        self.tableView.backgroundView = backgroundImageView

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        footerStackView.fitViewConstraintsTo(footerView)
        headerStackView.fitViewConstraintsTo(containerHeaderView)
        
        loginButton.fitLoginButtons(self)
        facebookButton.fitLoginButtons(self)
        
        orLabel.fitLoginLabels()
        forgotPasswordButton.fitLoginLabels()
        toggleButton.fitLoginLabels()
//        loginSegment.heightAnchor.constraintEqualToConstant(28).active = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if loginSegment.selectedSegmentIndex == 1 {
            didChangeLoginSegment()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loginButton.makeRoundCorners(90)
        facebookButton.makeRoundCorners(90)

//        if loginButton.subviews.count == 1 {
//            blur.frame = loginButton.bounds
//            blur.makeRoundCorners(90)
//            blur.clipsToBounds = true
//            blur.userInteractionEnabled = false
//            
//            loginButton.insertSubview(blur, atIndex: 0)
//            
//        }
    }
    
    func didTapCancel() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapToggle(sender: UIButton) {
        if loginSegment.selectedSegmentIndex == 0 {
            loginSegment.selectedSegmentIndex = 1
        } else {
            loginSegment.selectedSegmentIndex = 0
        }
        loginSegment.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    func didChangeLoginSegment() {
        tableView.reloadData()
        if loginSegment.selectedSegmentIndex == 0 {
//            footerView.bounds = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: Heights.FooterLogin.value)
            footerStackView.insertArrangedSubview(forgotPasswordButton, atIndex: 1)
//            footerStackView.updateConstraints()

            loginButton.setTitle("LOG IN", forState: .Normal)
            facebookButton.setAttributedTitle(NSAttributedString(string: "Log in with Facebook".uppercaseString), forState: .Normal)
            toggleButton.setTitle("Don't have an account? Sign Up!", forState: .Normal)
        } else {
            forgotPasswordButton.removeFromSuperview()
//            footerView.bounds = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: Heights.FooterSignup.value)


            loginButton.setTitle("SIGN UP", forState: .Normal)
            facebookButton.setAttributedTitle(NSAttributedString(string: "Sign up with Facebook".uppercaseString), forState: .Normal)
            toggleButton.setTitle("Already have an account? Log In.", forState: .Normal)

        }
//        tableView.reloadData()
    }

    // doesnt work because need to override the tableView touches began, not the controller touches began, but then that will break ability to select cells
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesBegan(touches, withEvent: event)
//        self.tableView.endEditing(true)
//    }
    
    func didTapForgotPassword(button: UIButton) {
        guard let url = NSURL(string: "https://www.plango.us/login/#/forgot-password") else {return}
        UIApplication.sharedApplication().openURL(url)
    }
    
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
        if textField == passwordTextField {
            textField.endEditing(true)
            didTapLogin(loginButton)
        }
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == usernameTextField {
            emailTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
//        textField.layer.borderWidth = 0.0
        
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
