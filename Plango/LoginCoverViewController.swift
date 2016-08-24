//
//  LoginCoverViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 8/24/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import SafariServices

class LoginCoverViewController: UIViewController {
    
    lazy var logoImageView: UIImageView = {
       let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .ScaleAspectFit
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Plango"
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.plangoWelcomeTitle()
        label.textAlignment = .Center
        label.numberOfLines = 1
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Re-use itineraries from like-minded travelers.\nGet offline maps and more!"
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.plangoBodyBig()
        label.textAlignment = .Center
        label.numberOfLines = 2
        return label
    }()
    
    lazy var signupButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.transparentGray()
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 3
        button.tintColor = UIColor.whiteColor()
        button.setTitle("SIGN UP", forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.plangoButton()
        button.addTarget(self, action: #selector(didTapLogin), forControlEvents: .TouchUpInside)
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
    
    lazy var termsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clearColor()
        button.tintColor = UIColor.whiteColor()
        button.setTitle("By signing up, I agree to Plango's Terms & Conditions and Privacy Policy", forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(didTapTerms), forControlEvents: .TouchUpInside)
        button.titleLabel?.font = UIFont.plangoSmallButton()
        button.titleLabel?.textAlignment = .Center
        button.titleLabel?.numberOfLines = 2
        return button
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
    
    lazy var containerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 44, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.height * 0.68))
        return view
    }()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserverForName(Notify.Timer.rawValue, object: nil, queue: nil) { (notification) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                
                let app = UIApplication.sharedApplication().delegate as! AppDelegate
                app.swapLoginControllerInTab()
                
            })
        }
        
        let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.image = UIImage(named: "login-bg")
        backgroundImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(backgroundImageView)
        
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(signupButton)
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(termsButton)

        containerView.addSubview(stackView)
        view.addSubview(containerView)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //autoconstraints
        stackView.fitViewConstraintsTo(containerView)
        
//        titleLabel.fitLoginLabels()
//        subtitleLabel.fitLoginLabels()
        logoImageView.heightAnchor.constraintEqualToConstant(60).active = true
        
        signupButton.fitLoginButtons(self)
        loginButton.fitLoginButtons(self)
        
        termsButton.fitLoginButtons(self)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //roundcorners
        signupButton.makeRoundCorners(90)
        loginButton.makeRoundCorners(90)

    }
    
    func didTapLogin(sender: UIButton) {
        let loginVC = LoginTableViewController()
        if sender == signupButton {
            loginVC.loginSegment.selectedSegmentIndex = 1
        } else {
            loginVC.loginSegment.selectedSegmentIndex = 0
        }
        showViewController(loginVC, sender: nil)
    }
    
    func didTapTerms(sender: UIButton) {
        guard let url = NSURL(string: "https://www.plango.us/terms.html") else {return}
        let safariVC = SFSafariViewController(URL: url)
        presentViewController(safariVC, animated: true, completion: nil)
    }

}
