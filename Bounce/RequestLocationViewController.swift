//
//  RequestLocationViewController.swift
//  bounce
//
//  Created by Steven on 9/6/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

import UIKit
import Darwin

class RequestLocationViewController: UIViewController {

    // MARK: - UI Elements
    
    let locationManager = CLLocationManager()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()

        titleLabel.text = "We need your location!"
        titleLabel.font = Constants.Fonts.Avenir.Large
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        
        self.view.addSubview(titleLabel)
        
        return titleLabel
    }()
    
    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "Intro-Map")
        let imageView = UIImageView(image: image)
        
        self.view.addSubview(imageView)
        
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        
        descriptionLabel.text = "We use your location to help you find others nearby to get home with, and to provide better suggestions for homepoints to join."
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
        
        imageView.sizeToHeight(self.view.frame.size.height * 0.28)
        imageView.centerHorizontallyInSuperview()
        imageView.positionBelowItem(titleLabel, offset: 64)
        
        continueButton.pinToBottomEdgeOfSuperview(offset: 50)
        continueButton.sizeToHeight(53)
        continueButton.pinToSideEdgesOfSuperview(offset: 30)
        
        descriptionLabel.positionAboveItem(continueButton, offset: 60)
        descriptionLabel.pinToSideEdgesOfSuperview(offset: 27)
    }
    
    // MARK: - Button Method
    
    func continuePressed() {
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            self.locationManager.requestAlwaysAuthorization()
        }
        
        let continueQueue = dispatch_queue_create("Continue Queue", nil)
        
        dispatch_async(continueQueue, {
            while (CLLocationManager.authorizationStatus() == .NotDetermined) {
                // Sleep for 10 ms
                usleep(100000)
            }
            
            let notificationsSet = (UIApplication.sharedApplication().currentUserNotificationSettings().types != .None)
            
            dispatch_async(dispatch_get_main_queue()) {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.titleLabel.alpha = 0.0
                    self.imageView.alpha = 0.0
                    self.descriptionLabel.alpha = 0.0
                    self.continueButton.titleLabel?.alpha = (notificationsSet) ? 0.0 : 1.0
                    }, completion: { (Bool) -> Void in
                        let destinationViewController = (notificationsSet) ? StudentStatusViewController(animated: true) : RequestPushNotificationsViewController()
                        self.presentViewController(destinationViewController, animated: false, completion: nil)
                })
            }
        })
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
}
