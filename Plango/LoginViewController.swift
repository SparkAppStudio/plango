//
//  LoginViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SafariServices


class LoginViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    enum Heights: Int {
        case footerLogin
        case footerSignup
        case header
        var value: CGFloat {
            switch self {
            case .footerLogin: return 130 //loginButton(50) + forgotButton (24) + toggleButton (24) + spacing (8x2) + topMargin (16)
            case .footerSignup: return 98 //loginButton(50) + toggleButton (24) + spacing (8) + topMargin (16)
            case .header: return 114 //facebookButton(50) + orLabel (24) + spacing (8) + top and bottom Margins (32)
            }
        }
    }
    
    var tableView: UITableView!
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 4, y: 23, width: 30, height: 30)) //image is 12x13, centered so x is small but touch area bigger, 16 and 36 margins
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.setImage(UIImage(named: "close"), for: UIControlState())
        button.imageView?.contentMode = .center
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return button
    }()
    
    lazy var usernameTextField: UITextField = {
        let text = UITextField()
        text.borderStyle = .none
        text.placeholder = "Username"
        text.font = UIFont.plangoBodyBig()
        text.textColor = UIColor.plangoTextLight()
        text.keyboardType = .asciiCapable
        text.returnKeyType = .next
        text.autocorrectionType = .no
        text.autocapitalizationType = .none
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
        text.borderStyle = .none
        text.placeholder = "Email Address"
        text.font = UIFont.plangoBodyBig()
        text.textColor = UIColor.plangoTextLight()
        text.keyboardType = .emailAddress
        text.returnKeyType = .next
        text.autocorrectionType = .no
        text.autocapitalizationType = .none
        text.delegate = self
        return text
    }()
    
    lazy var passwordTextField: UITextField = {
        let text = UITextField()
        text.borderStyle = .none
        text.placeholder = "Password"
        text.font = UIFont.plangoBodyBig()
        text.textColor = UIColor.plangoTextLight()
        text.isSecureTextEntry = true
        text.returnKeyType = .go
        text.autocorrectionType = .no
        text.autocapitalizationType = .none
        text.delegate = self
        return text
    }()
    
    //this is used to manage the state but not the UI so its never added to the view hierarchy
    lazy var loginSegment: UISegmentedControl = {
        let titles = ["LOG IN", "SIGN UP"]
        let segment = UISegmentedControl(items: titles)
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(LoginViewController.didChangeLoginSegment), for: .valueChanged)
        segment.sizeToFit()
        segment.tintColor = UIColor.white
        return segment
    }()
    
    lazy var toggleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.setTitle("Don't have an account? Sign Up!", for: UIControlState())
        button.addTarget(self, action: #selector(didTapToggle), for: .touchUpInside)
        button.titleLabel?.font = UIFont.plangoSmallButton()
        
        return button
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.transparentGray()
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        button.tintColor = UIColor.white
        button.setTitle("LOG IN", for: UIControlState())
        button.titleLabel?.font = UIFont.plangoButton()
        button.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        return button
    }()
    
    lazy var footerView: UIView = {
       let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: Heights.footerLogin.value))
        return view
    }()
    
    lazy var containerHeaderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: Heights.header.value))
        return view
    }()

    lazy var orLabel: UILabel = {
        let label = UILabel()
        label.text = "OR"
        label.textColor = UIColor.white
        label.font = UIFont.plangoButton()
        label.textAlignment = .center
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 8
        view.distribution = .equalSpacing
        view.alignment = .center
        return view
    }()
    
    lazy var headerStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 8
        view.distribution = .equalSpacing
        view.alignment = .center
        return view
    }()
    
    lazy var footerStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 8
        view.distribution = .equalSpacing
        view.alignment = .center
        return view
    }()
    
    lazy var facebookButton: FBSDKLoginButton = {
       let button = FBSDKLoginButton()
        button.delegate = self
        button.readPermissions = ["public_profile", "email", "user_friends"]
        button.setAttributedTitle(NSAttributedString(string: "Log in with Facebook".uppercased()), for: UIControlState())
        button.titleLabel?.font = UIFont.plangoButton()
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3

        return button
    }()
    
    lazy var forgotPasswordButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.setTitle("Forgot Password?", for: UIControlState())
        button.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
        button.titleLabel?.font = UIFont.plangoSmallButton()
        return button

    }()
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableView.endEditing(true)
        //this removes a warning which gets thrown if i only use "keyboardDismissMode" i think bc the textView inside the cells
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: UIScreen.main.bounds)
        tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
//        tableView = UITableView(frame: CGRect(x: 0, y: 36, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 36))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16)

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Notify.Timer.rawValue), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async(execute: { () -> Void in
                self.dismissBothControllers()
            })
        }
        
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "username")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "usernameemail")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "email")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "password")
        
        
        
//        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()
        let backgroundImageView = UIImageView(frame: tableView.frame)
        backgroundImageView.image = UIImage(named: "login-background")
        backgroundImageView.contentMode = .scaleAspectFill
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if loginSegment.selectedSegmentIndex == 1 {
            didChangeLoginSegment()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    @objc func didTapCancel() {
        tableView.endEditing(true)
        dismissBothControllers()
    }
    
    func dismissBothControllers() {
        if let root = presentingViewController?.presentingViewController {
            root.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func didTapToggle(_ sender: UIButton) {
        if loginSegment.selectedSegmentIndex == 0 {
            loginSegment.selectedSegmentIndex = 1
        } else {
            loginSegment.selectedSegmentIndex = 0
        }
        loginSegment.sendActions(for: UIControlEvents.valueChanged)
    }
    
    @objc func didChangeLoginSegment() {
        tableView.reloadData()
        if loginSegment.selectedSegmentIndex == 0 {
//            footerView.bounds = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: Heights.FooterLogin.value)
            footerStackView.insertArrangedSubview(forgotPasswordButton, at: 1)
//            footerStackView.updateConstraints()

            loginButton.setTitle("LOG IN", for: UIControlState())
            facebookButton.setAttributedTitle(NSAttributedString(string: "Log in with Facebook".uppercased()), for: UIControlState())
            toggleButton.setTitle("Don't have an account? Sign Up!", for: UIControlState())
        } else {
            forgotPasswordButton.removeFromSuperview()
//            footerView.bounds = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: Heights.FooterSignup.value)


            loginButton.setTitle("SIGN UP", for: UIControlState())
            facebookButton.setAttributedTitle(NSAttributedString(string: "Sign up with Facebook".uppercased()), for: UIControlState())
            toggleButton.setTitle("Already have an account? Log In.", for: UIControlState())

        }
//        tableView.reloadData()
    }

    // doesnt work because need to override the tableView touches began, not the controller touches began, but then that will break ability to select cells
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesBegan(touches, withEvent: event)
//        self.tableView.endEditing(true)
//    }
    
    @objc func didTapForgotPassword(_ sender: UIButton) {
        guard let url = URL(string: "https://www.plango.us/login/#/forgot-password") else {return}
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    @objc func didTapLogin(_ button: UIButton) {
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
                let userInfo = ["controller" : self, "userEmail" : userEmail.lowercased(), "password" : password] as [String : Any]
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notify.Login.rawValue), object: nil, userInfo: userInfo)
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
                let userInfo = ["controller" : self, "userEmail" : userEmail.lowercased(), "password" : password, "userName" : userName] as [String : Any]
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notify.NewUser.rawValue), object: nil, userInfo: userInfo)
            }

        }
    }

    
    // MARK: - Text Field
    
    func processTextField(_ textField: UITextField) {
        _ = textField.text?.trimWhiteSpace()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
//        textField.layer.borderWidth = 0.0
        
        processTextField(textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loginSegment.selectedSegmentIndex == 0 {
            return 2
        } else {
            return 3
        }
    }
    
    func cellFrame(_ cell: UITableViewCell) -> CGRect {
        return CGRect(x: 16, y: 4, width: cell.contentView.frame.width - 32, height: cell.contentView.frame.height - 8)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if loginSegment.selectedSegmentIndex == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "email", for: indexPath)
                emailTextField.frame = cellFrame(cell)
                cell.contentView.addSubview(emailTextField)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "password", for: indexPath)
                passwordTextField.frame = cellFrame(cell)
                cell.contentView.addSubview(passwordTextField)
                return cell
            }
        } else {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "username", for: indexPath)
                usernameTextField.frame = cellFrame(cell)
                cell.contentView.addSubview(usernameTextField)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "email", for: indexPath)
                emailTextField.frame = cellFrame(cell)
                cell.contentView.addSubview(emailTextField)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "password", for: indexPath)
                passwordTextField.frame = cellFrame(cell)
                cell.contentView.addSubview(passwordTextField)
                return cell
            }
        }
        

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (cell.responds(to: #selector(getter: UIView.tintColor))){
            if (tableView == self.tableView) {
                let cornerRadius : CGFloat = 3.0
                cell.backgroundColor = UIColor.clear
                let layer: CAShapeLayer = CAShapeLayer()
                let pathRef:CGMutablePath = CGMutablePath()
                let bounds: CGRect = cell.bounds.insetBy(dx: 8, dy: 0)
//                var addLine: Bool = false //causes problems with normal tableView separator
                
                if (indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
                    pathRef.__addRoundedRect(transform: nil, rect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
                } else if (indexPath.row == 0) {
                    pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))

                    pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.minY), tangent2End: CGPoint(x: bounds.midX, y: bounds.minY), radius: cornerRadius)

                    pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.minY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)

                    pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
//                    addLine = true
                } else if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
                    pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.minY))

                    pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.midX, y: bounds.maxY), radius: cornerRadius)

                    pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)

                    pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
                } else {
                    pathRef.addRect(bounds)
//                    addLine = true
                }
                
                layer.path = pathRef
//                layer.fillColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 0.8).CGColor
                layer.fillColor = UIColor.white.cgColor
                
//                if (addLine == true) {
//                    let lineLayer: CALayer = CALayer()
//                    let lineHeight: CGFloat = (1.0 / UIScreen.mainScreen().scale)
//                    lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight)
//                    lineLayer.backgroundColor = tableView.separatorColor!.CGColor
//                    layer.addSublayer(lineLayer)
//                }
                let testView: UIView = UIView(frame: bounds)
                testView.layer.insertSublayer(layer, at: 0)
                testView.backgroundColor = UIColor.clear
                cell.backgroundView = testView
            }
        }
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            printError(error)
            self.tableView.quickToast(error.localizedDescription)
        } else if result.isCancelled == false {
            if loginSegment.selectedSegmentIndex == 0 {
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notify.Login.rawValue), object: nil, userInfo: ["controller" : self, "FBSDKLoginResult":result])
            } else {
                let confirmVC = LoginConfirmViewController()
                confirmVC.facebookResult = result
//                self.addChildViewController(confirmVC)
                self.present(confirmVC, animated: true, completion: nil)
            }
        } else {
            //user cancelled fb login
        }

    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Notify.Logout.rawValue), object: nil, userInfo: ["controller" : self])
    }
}
