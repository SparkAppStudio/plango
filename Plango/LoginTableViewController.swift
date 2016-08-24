//
//  LoginTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SafariServices


class LoginTableViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
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
    
    var tableView: UITableView!
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 16, y: 36, width: 12, height: 13))
        button.backgroundColor = UIColor.clearColor()
        button.tintColor = UIColor.whiteColor()
        button.setImage(UIImage(named: "close"), forState: .Normal)
        button.addTarget(self, action: #selector(didTapCancel), forControlEvents: .TouchUpInside)
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
    
    //this is used to manage the state but not the UI so its never added to the view hierarchy
    lazy var loginSegment: UISegmentedControl = {
        let titles = ["LOG IN", "SIGN UP"]
        let segment = UISegmentedControl(items: titles)
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(LoginTableViewController.didChangeLoginSegment), forControlEvents: .ValueChanged)
        segment.sizeToFit()
        segment.tintColor = UIColor.whiteColor()
        return segment
    }()
    
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
        label.textAlignment = .Center
        return label
    }()
    
    lazy var stackView: UIStackView = {
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
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        tableView.endEditing(true)
        //this removes a warning which gets thrown if i only use "keyboardDismissMode" i think bc the textView inside the cells
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: UIScreen.mainScreen().bounds)
        tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
//        tableView = UITableView(frame: CGRect(x: 0, y: 36, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 36))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16)

        NSNotificationCenter.defaultCenter().addObserverForName(Notify.Timer.rawValue, object: nil, queue: nil) { (notification) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
//                let app = UIApplication.sharedApplication().delegate as! AppDelegate
//                app.swapLoginControllerInTab()

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
        backgroundImageView.image = UIImage(named: "login-background")
        backgroundImageView.contentMode = .ScaleAspectFill
        tableView.backgroundView = backgroundImageView

        view.addSubview(tableView)

        view.addSubview(cancelButton)
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
        tableView.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    func didTapForgotPassword(sender: UIButton) {
        guard let url = NSURL(string: "https://www.plango.us/login/#/forgot-password") else {return}
        let safariVC = SFSafariViewController(URL: url)
        presentViewController(safariVC, animated: true, completion: nil)
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

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loginSegment.selectedSegmentIndex == 0 {
            return 2
        } else {
            return 3
        }
    }
    
    func cellFrame(cell: UITableViewCell) -> CGRect {
        return CGRectMake(16, 4, cell.contentView.frame.width - 32, cell.contentView.frame.height - 8)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if loginSegment.selectedSegmentIndex == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("email", forIndexPath: indexPath)
                emailTextField.frame = cellFrame(cell)
                cell.contentView.addSubview(emailTextField)
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("password", forIndexPath: indexPath)
                passwordTextField.frame = cellFrame(cell)
                cell.contentView.addSubview(passwordTextField)
                return cell
            }
        } else {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("username", forIndexPath: indexPath)
                usernameTextField.frame = cellFrame(cell)
                cell.contentView.addSubview(usernameTextField)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("email", forIndexPath: indexPath)
                emailTextField.frame = cellFrame(cell)
                cell.contentView.addSubview(emailTextField)
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("password", forIndexPath: indexPath)
                passwordTextField.frame = cellFrame(cell)
                cell.contentView.addSubview(passwordTextField)
                return cell
            }
        }
        

    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (cell.respondsToSelector(Selector("tintColor"))){
            if (tableView == self.tableView) {
                let cornerRadius : CGFloat = 3.0
                cell.backgroundColor = UIColor.clearColor()
                let layer: CAShapeLayer = CAShapeLayer()
                let pathRef:CGMutablePathRef = CGPathCreateMutable()
                let bounds: CGRect = CGRectInset(cell.bounds, 8, 0)
//                var addLine: Bool = false //causes problems with normal tableView separator
                
                if (indexPath.row == 0 && indexPath.row == tableView.numberOfRowsInSection(indexPath.section)-1) {
                    CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius)
                } else if (indexPath.row == 0) {
                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds))
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius)
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius)
                    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))
//                    addLine = true
                } else if (indexPath.row == tableView.numberOfRowsInSection(indexPath.section)-1) {
                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds))
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius)
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius)
                    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds))
                } else {
                    CGPathAddRect(pathRef, nil, bounds)
//                    addLine = true
                }
                
                layer.path = pathRef
//                layer.fillColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.8).CGColor
                layer.fillColor = UIColor.whiteColor().CGColor
                
//                if (addLine == true) {
//                    let lineLayer: CALayer = CALayer()
//                    let lineHeight: CGFloat = (1.0 / UIScreen.mainScreen().scale)
//                    lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight)
//                    lineLayer.backgroundColor = tableView.separatorColor!.CGColor
//                    layer.addSublayer(lineLayer)
//                }
                let testView: UIView = UIView(frame: bounds)
                testView.layer.insertSublayer(layer, atIndex: 0)
                testView.backgroundColor = UIColor.clearColor()
                cell.backgroundView = testView
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
