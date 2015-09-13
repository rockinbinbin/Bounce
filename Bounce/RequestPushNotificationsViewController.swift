//
//  RequestPushNotificationsViewController.swift
//  bounce
//
//  Created by Steven on 9/6/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

import UIKit

class RequestPushNotificationsViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        
        titleLabel.text = "We need push notifications!"
        titleLabel.font = Constants.Fonts.Avenir.Large
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        
        self.view.addSubview(titleLabel)
        
        return titleLabel
        }()
    
    private lazy var phoneImageView: UIImageView = {
        let image = UIImage(named: "Intro-Phone")
        let phoneImageView = UIImageView(image: image)
        
        self.view.addSubview(phoneImageView)
        
        return phoneImageView
        }()
    
    private lazy var notificationImageView: UIImageView = {
        let image = UIImage(named: "Intro-Notification")
        let notificationImageView = UIImageView(image: image)
        
        self.view.addSubview(notificationImageView)
        
        return notificationImageView
        }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        
        descriptionLabel.text = "We'll let you know when you get a message via chat or leaving request."
        descriptionLabel.font = Constants.Fonts.Avenir.Medium
        descriptionLabel.textColor = UIColor.whiteColor()
        descriptionLabel.textAlignment = .Center
        descriptionLabel.lineBreakMode = .ByWordWrapping
        descriptionLabel.numberOfLines = 0
        
        self.view.addSubview(descriptionLabel)
        
        return descriptionLabel
        }()
    
    private lazy var continueButton: RoundedRectButton = {
        let continueButton = RoundedRectButton(text: "Continue")
        
        continueButton.addTarget(self, action: "continuePressed", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(continueButton)
        
        return continueButton
        }()
    
    // MARK: - UI Appearance and Layout
    
    private func configureViewControllerAppearance() {
        self.view.backgroundColor = Constants.Colors.BounceRed
        UIApplication.sharedApplication().statusBarHidden = true
        self.navigationController?.navigationBar.hidden = true
    }
    
    private func layoutViews() {
        titleLabel.centerHorizontallyInSuperview()
        titleLabel.pinToTopEdgeOfSuperview(offset: 50)
        
        let originalImageSize = self.phoneImageView.image?.size
        phoneImageView.sizeToHeight(self.view.frame.size.height * 0.30)
        phoneImageView.sizeToWidth(self.view.frame.size.height * 0.30 * originalImageSize!.width / originalImageSize!.height)
        phoneImageView.centerHorizontallyInSuperview()
        phoneImageView.positionBelowItem(titleLabel, offset: 64)

        let notificationWidth = originalImageSize!.width * 0.4
        notificationImageView.sizeToWidth(notificationWidth)
        notificationImageView.sizeToHeight(notificationWidth)
        notificationImageView.positionToTheRightOfItem(phoneImageView, offset: -(notificationWidth / 2.0))
        notificationImageView.positionAboveItem(phoneImageView, offset: -(notificationWidth * 2.0 / 3.0))
        
        continueButton.pinToBottomEdgeOfSuperview(offset: 50)
        continueButton.sizeToHeight(53)
        continueButton.pinToSideEdgesOfSuperview(offset: 30)
        
        descriptionLabel.positionAboveItem(continueButton, offset: 60)
        descriptionLabel.pinToSideEdgesOfSuperview(offset: 27)
    }
    
    // MARK: - Button Method
    
    func continuePressed() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.titleLabel.alpha = 0.0
            self.phoneImageView.alpha = 0.0
            self.notificationImageView.alpha = 0.0
            self.descriptionLabel.alpha = 0.0
            self.continueButton.titleLabel?.alpha = 0.0
            }, completion: { (Bool) -> Void in
                self.registerForNotifications()
                self.presentViewController(StudentStatusViewController(animated: true), animated: false, completion: nil)
        })
    }
    
    func registerForNotifications() {
        let application = UIApplication.sharedApplication()
        
        if application.respondsToSelector(Selector("registerUserNotificationSettings:")) {
            let settings = UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureViewControllerAppearance()
        self.layoutViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.titleLabel.alpha = 0.0
        self.phoneImageView.alpha = 0.0
        self.notificationImageView.alpha = 0.0
        self.descriptionLabel.alpha = 0.0
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.titleLabel.alpha = 1.0
            self.phoneImageView.alpha = 1.0
            self.notificationImageView.alpha = 1.0
            self.descriptionLabel.alpha = 1.0
            }, completion: nil
        )
    }
}
