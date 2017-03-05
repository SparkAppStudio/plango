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
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Plango"
        label.textColor = UIColor.white
        label.font = UIFont.plangoWelcomeTitle()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Re-use itineraries from like-minded travelers.\nGet offline maps and more!"
        label.textColor = UIColor.white
        label.font = UIFont.plangoBodyBig()
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    lazy var signupButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.transparentGray()
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        button.tintColor = UIColor.white
        button.setTitle("SIGN UP", for: UIControlState())
        button.titleLabel?.font = UIFont.plangoButton()
        button.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
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
    
    lazy var termsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.setTitle("By signing up, I agree to Plango's Terms & Conditions and Privacy Policy.", for: UIControlState())
        button.addTarget(self, action: #selector(didTapTerms), for: .touchUpInside)
        button.titleLabel?.font = UIFont.plangoSmallButton()
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 2
        return button
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
    
    lazy var containerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 44, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.height * 0.68))
        return view
    }()
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Notify.Timer.rawValue), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async(execute: { () -> Void in
                let app = UIApplication.shared.delegate as! AppDelegate

                if Plango.sharedInstance.currentUser?.confirmed == false {
                    //if new user has not been confirmed, immediately log them out to prevent inbetween state. They can log in once they click the confirm email
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Notify.Logout.rawValue), object: nil, userInfo: ["controller": self])

                } else {
                    //finish the login process by swapping the controllers
                    app.swapLoginControllerInTab()
                }
                
            })
        }
        
        let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.image = UIImage(named: "login-background")
        backgroundImageView.contentMode = .scaleAspectFill
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
        logoImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        signupButton.fitLoginButtons(self)
        loginButton.fitLoginButtons(self)
        
        termsButton.fitLoginButtons(self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //roundcorners
        signupButton.makeRoundCorners(90)
        loginButton.makeRoundCorners(90)

    }
    
    func didTapLogin(_ sender: UIButton) {
        let loginVC = LoginViewController()
        if sender == signupButton {
            loginVC.loginSegment.selectedSegmentIndex = 1
        } else {
            loginVC.loginSegment.selectedSegmentIndex = 0
        }
        present(loginVC, animated: true, completion: nil)
    }
    
    func didTapTerms(_ sender: UIButton) {
        guard let url = URL(string: "https://www.plango.us/terms.html") else {return}
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }

}
