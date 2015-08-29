//
//  StudentStatusViewController.swift
//  Bounce
//
//  Created by Steven on 7/22/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

import UIKit

class StudentStatusViewController : UIViewController {
    var titleLabel = UILabel()
    var contentLabel = UILabel()
    var yesButton = RoundedRectButton(text: "Yes, I currently go to college")
    let noButton = RoundedRectButton(text: "No, let's get started!")

    override func viewDidLoad() {
        self.view.backgroundColor = Constants.Colors.BounceRed
        UIApplication.sharedApplication().statusBarHidden = true
        self.navigationController?.navigationBar.hidden = true
        
        yesButton.addTarget(self, action: "studentButtonPressed:", forControlEvents: .TouchUpInside)
        noButton.addTarget(self, action: "nonStudentButtonPressed:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(noButton)
        self.view.addSubview(yesButton)
        
        noButton.pinToBottomEdgeOfSuperview(offset: 50)
        noButton.sizeToHeight(53)
        noButton.pinToSideEdgesOfSuperview(offset: 30)
        
        yesButton.sizeToWidthAndHeightOfItem(noButton)
        yesButton.positionAboveItem(noButton, offset: 10)
        yesButton.pinToSideEdgesOfSuperview(offset: 30)
        
        // Image
        
        let imageView = UIImageView()
        let image = UIImage(named: "Intro-Hat")
        imageView.image = image
        self.view.addSubview(imageView)
        
        let originalSize = image?.size
        imageView.centerHorizontallyInSuperview()
        imageView.pinToTopEdgeOfSuperview(offset: self.view.frame.size.height * 0.05)
        imageView.pinToSideEdgesOfSuperview(offset: self.view.frame.size.width * 0.20)
        
        let constraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Width, multiplier: originalSize!.height / originalSize!.width, constant: 0.0)
  
        self.view.addConstraint(constraint)
        
        // Title label
        
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "Are you a student?"
        titleLabel.textAlignment = .Center
        titleLabel.font = Constants.Fonts.Avenir.Large
        self.view.addSubview(titleLabel)

        titleLabel.centerHorizontallyInSuperview()
        titleLabel.positionBelowItem(imageView, offset: self.view.frame.size.height * 0.025)
        
        // Do not display this label on iPhone 4s
        if (view.frame.size.height > 480.0) {
            contentLabel = UILabel()
            contentLabel.textColor = UIColor.whiteColor()
            contentLabel.text = "Both students and non-students can use Bounce."
            contentLabel.textAlignment = .Center
            contentLabel.lineBreakMode = .ByWordWrapping
            contentLabel.numberOfLines = 0
            contentLabel.font = Constants.Fonts.Avenir.Medium

            view.addSubview(contentLabel)
            
            contentLabel.pinToSideEdgesOfSuperview(offset: self.view.frame.size.height * 0.05)
            contentLabel.positionBelowItem(titleLabel, offset: 20)
        }
    }
    
    func studentButtonPressed(sender: UIButton!) {
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.contentLabel.alpha = 0.0
                self.yesButton.alpha = 0.0
                self.noButton.alpha = 0.0
            }, completion: { (Bool) -> Void in
                self.presentViewController(StudentVerificationViewController(), animated: false, completion: nil)
            }
        )
    }
    
    func nonStudentButtonPressed(sender: UIButton!) {
        PFUser.currentUser()!.setValue(true, forKey: "setupComplete")
        PFUser.currentUser()?.saveInBackgroundWithBlock(nil)
        self.presentViewController(RootTabBarController(), animated: false, completion: nil)
    }
}
