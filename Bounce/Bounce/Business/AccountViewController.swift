//
//  AccountViewController.swift
//  Bounce
//
//  Created by Steven on 7/27/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

import UIKit
import CoreData

class AccountViewController: UIViewController {
    
    var delegate: MainScrollContainerDelegate?
    
    // MARK: - UI Elements
    
    let scrollView = UIScrollView()
    let optionsView = UIView()
    let accountLabel = UILabel()
    let profilePictureView = UIImageView()
    let profileName = UILabel()
    let studentStatusLabel = UILabel()
    let statusBarCover = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViewController()
        self.setupScrollView()

        self.renderAccountLabel()
        self.renderProfilePicture()
        self.renderProfileName()
        self.renderStudentStatusLabel()
        
        self.renderOptions()

        self.view.addSubview(scrollView)
        
        self.renderStatusBarCover()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate?.setScrolling(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.setScrolling(false)
    }
    
    // MARK: - UI Rendering Helpers
    
    func renderAccountLabel() {
        accountLabel.text = "Account"
        accountLabel.font = UIFont(name: "AvenirNext-Medium", size: 21)
        accountLabel.textColor = UIColor.whiteColor()
        scrollView.addSubview(accountLabel)
        
        accountLabel.centerHorizontallyInSuperview()
        accountLabel.pinToTopEdgeOfSuperview(offset: 30)
    }
    
    func renderProfilePicture() {
        // Profile Info
        
        let profilePicture = UIImage(named: "Account-DefaultPhoto")
        profilePictureView.image = profilePicture
        profilePictureView.layer.borderWidth = 4.0
        profilePictureView.layer.borderColor = UIColor.whiteColor().CGColor
        profilePictureView.layer.cornerRadius = 50
        profilePictureView.clipsToBounds = true
        
        scrollView.addSubview(profilePictureView)
        
        profilePictureView.centerHorizontallyInSuperview()
        profilePictureView.sizeToWidthAndHeight(100)
        profilePictureView.positionBelowItem(accountLabel, offset: 15)
        
        if let verified : Bool = PFUser.currentUser()?.objectForKey("emailVerified") as? Bool {
            if verified {
                self.renderStudentVerifiedCheckmark()
            }
        } else {
            PFUser.currentUser()?.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
                if let verified: Bool = object?.objectForKey("emailVerified") as? Bool {
                    if verified {
                        let email = PFUser.currentUser()!.valueForKey("email") as! String

                        if let universityName = UniversityEmail.getUniversity(email) {
                            self.studentStatusLabel.text = "Student, \(universityName)"
                        } else {
                            self.studentStatusLabel.text = "Verified university student"
                        }

                        self.renderStudentVerifiedCheckmark()
                    }
                }
            })
        }
        
        // Check for saved photo, and display that if found
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let imagePath = paths.stringByAppendingPathComponent("cachedProfilePicture.png")
        if let savedProfilePicture = UIImage(contentsOfFile: imagePath) {
            profilePictureView.image = savedProfilePicture
        }
        
        let facebookId = PFUser.currentUser()?.objectForKey("facebook_id") as? String
        
        if let id = facebookId as String! {
            let pictureURL = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large")
            
            let imageLoadingQueue = dispatch_queue_create("Image Queue", nil)
            
            dispatch_async(imageLoadingQueue, {
                let profilePicture = UIImage(data: NSData(contentsOfURL: pictureURL!)!)
                dispatch_async(dispatch_get_main_queue(), {
                    self.profilePictureView.image = profilePicture
                    let imageData = UIImagePNGRepresentation(profilePicture)
                    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
                    let imagePath = paths.stringByAppendingPathComponent("cachedProfilePicture.png")
                    
                    if imageData.writeToFile(imagePath, atomically: false) {
                        NSUserDefaults.standardUserDefaults().setObject(imagePath, forKey: "imagePath")
                    }
                })
            })
        }
    }
    
    func renderStudentVerifiedCheckmark() {
        let checkmarkSize : CGFloat = 30
        let checkmark = UIImage(named: "Account-Check")
        let checkmarkView = UIImageView(image: checkmark)
        self.scrollView.addSubview(checkmarkView)
        checkmarkView.sizeToWidthAndHeight(checkmarkSize)
        checkmarkView.positionBelowItem(self.profilePictureView, offset: -checkmarkSize)
        checkmarkView.positionToTheRightOfItem(self.profilePictureView, offset: -checkmarkSize)
    }
    
    func renderProfileName() {
        profileName.font = UIFont(name: "AvenirNext-Regular", size: 20)
        profileName.textColor = UIColor.whiteColor()
        scrollView.addSubview(profileName)
        profileName.centerHorizontallyInSuperview()
        profileName.positionBelowItem(profilePictureView, offset: 15)
        
        // Save the user name
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"AccountInfo")
        var error: NSError?
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject]
        
        if let results : [NSManagedObject] = fetchedResults {
            if results.count > 0 {
                let userFullName = results[0].valueForKey("name") as! String
                self.profileName.text = userFullName
            }
        }
        
        let request = FBRequest.requestForMe()
        request.startWithCompletionHandler({ (connection: FBRequestConnection!, result: AnyObject?, error: NSError!) -> Void in
            if error != nil {
                println(error)
            } else {
                let resultDict = result as? NSDictionary
                
                if resultDict != nil {
                    let resultDict = result as? NSDictionary
                    if let name = resultDict?["name"] as? String {
                        if self.profileName.text != name {
                            self.profileName.text = name
                            
                            let entity =  NSEntityDescription.entityForName("AccountInfo",
                                inManagedObjectContext:
                                managedContext)
                            
                            let accountInfo = NSManagedObject(entity: entity!,
                                insertIntoManagedObjectContext:managedContext)
                            
                            accountInfo.setValue(name, forKey: "name")
                            
                            var error: NSError?
                            if !managedContext.save(&error) {
                                println("Could not save \(error), \(error?.userInfo)")
                            }
                        }
                    }
                }
            }
        })

    }
    
    func renderStudentStatusLabel() {
        if let emailVerified = PFUser.currentUser()!.valueForKey("emailVerified") as? Bool {

            let email = PFUser.currentUser()!.valueForKey("email") as! String
            
            // Verified student
            if emailVerified {
                if let universityName = UniversityEmail.getUniversity(email) {
                    studentStatusLabel.text = "Student, \(universityName)"
                } else {
                    studentStatusLabel.text = "Verified university student"
                }

            // Unverified Student
            } else {
                if let universityName = UniversityEmail.getUniversity(email) {
                    studentStatusLabel.text = "Unverified student, \(universityName)"
                } else {
                    studentStatusLabel.text = "Unverified university student"
                }
            }

        // Not a student
        } else {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            let fetchRequest = NSFetchRequest(entityName:"AccountInfo")
            var error: NSError?
            let fetchedResults =
            managedContext.executeFetchRequest(fetchRequest,
                error: &error) as? [NSManagedObject]
            
            if let results : [NSManagedObject] = fetchedResults {
                if results.count > 0 {
                    if let location = results[0].valueForKey("location") as? String {
                        studentStatusLabel.text = location
                    } else {
                        studentStatusLabel.text = "Bounce User"
                    }
                }
            }

        }

        studentStatusLabel.textAlignment = .Center
        studentStatusLabel.lineBreakMode = .ByWordWrapping
        studentStatusLabel.numberOfLines = 0
        studentStatusLabel.font = UIFont(name: "AvenirNext-Medium", size: 16)
        studentStatusLabel.textColor = UIColor(white: 0.0, alpha: 0.21)
        scrollView.addSubview(studentStatusLabel)
        studentStatusLabel.centerHorizontallyInSuperview()
        studentStatusLabel.positionBelowItem(profileName, offset: 3)
        studentStatusLabel.sizeToWidth(self.view.frame.width - 20)
    }

    func renderOptions() {
        
        let buttonHeight : CGFloat = 44.0
        
        // Inviting Friends
        
        let inviteFriendsLabel = OptionsTitleLabel(text: "INVITE FRIENDS")
        optionsView.addSubview(inviteFriendsLabel)
        inviteFriendsLabel.pinToTopEdgeOfSuperview(offset: 30)
        inviteFriendsLabel.pinToLeftEdgeOfSuperview(offset: 15)
        
        let facebookImage = UIImage(named: "Facebook-Rounded-Square-Dark")
        let inviteFriendsButton = OptionsButton(text: "Facebook friends", image: facebookImage, buttonHeight: buttonHeight)
        optionsView.addSubview(inviteFriendsButton)
        inviteFriendsButton.positionBelowItem(inviteFriendsLabel, offset: 15)
        inviteFriendsButton.pinToSideEdgesOfSuperview()
        inviteFriendsButton.sizeToHeight(buttonHeight)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"AccountInfo")
        var error: NSError?
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject]
        
        if let results : [NSManagedObject] = fetchedResults {
            if results.count > 0 {
                let friendCount = results[0].valueForKey("friendCount") as! Int
                inviteFriendsButton.setTitle("\(friendCount) Facebook friends", forState: .Normal)
            }
        }
        
        let request = FBRequest.requestForMyFriends()
        request.startWithCompletionHandler({ (connection: FBRequestConnection!, result: AnyObject?, error: NSError!) -> Void in
            if error != nil {
                println(error)
            } else {
                let resultDict = result as? NSDictionary
                
                if resultDict != nil {
                    let resultDict = result as? NSDictionary
                    if let summaryDict = resultDict?["summary"] as? NSDictionary {
                        let friendCount = (summaryDict["total_count"] as! Int)
                        inviteFriendsButton.setTitle("\(friendCount) Facebook friends", forState: .Normal)
                    }
                }
            }
        })
        
        // Support
        
        let supportLabel = OptionsTitleLabel(text: "SUPPORT")
        optionsView.addSubview(supportLabel)
        supportLabel.positionBelowItem(inviteFriendsButton, offset: 30)
        supportLabel.pinToLeftEdgeOfSuperview(offset: 15)
        
        let sendAppFeedback = OptionsButton(text: "Send feedback about Bounce")
        sendAppFeedback.addTarget(self, action: "sendEmail", forControlEvents: .TouchUpInside)
        optionsView.addSubview(sendAppFeedback)
        sendAppFeedback.positionBelowItem(supportLabel, offset: 15)
        sendAppFeedback.pinToSideEdgesOfSuperview()
        sendAppFeedback.sizeToHeight(buttonHeight)
        
        let reportButton = OptionsButton(text: "Report an incident")
        reportButton.addTarget(self, action: "reportIncidentPressed", forControlEvents: .TouchUpInside)
        optionsView.addSubview(reportButton)
        reportButton.positionBelowItem(sendAppFeedback, offset: -1)
        reportButton.pinToSideEdgesOfSuperview()
        reportButton.sizeToHeight(buttonHeight)
        
        // About
        
        let aboutLabel = OptionsTitleLabel(text: "ABOUT")
        optionsView.addSubview(aboutLabel)
        aboutLabel.positionBelowItem(reportButton, offset: 30)
        aboutLabel.pinToLeftEdgeOfSuperview(offset: 15)
        
        let privacyPolicy = OptionsButton(text: "Privacy Policy")
        optionsView.addSubview(privacyPolicy)
        privacyPolicy.positionBelowItem(aboutLabel, offset: 15)
        privacyPolicy.pinToSideEdgesOfSuperview()
        privacyPolicy.sizeToHeight(buttonHeight)
        
        let termsOfUse = OptionsButton(text: "Terms of Use")
        optionsView.addSubview(termsOfUse)
        termsOfUse.positionBelowItem(privacyPolicy, offset: -1)
        termsOfUse.pinToSideEdgesOfSuperview()
        termsOfUse.sizeToHeight(buttonHeight)
        
        // Log out
        
        let logOutButton = OptionsButton(text: "Log out 😥")
        logOutButton.addTarget(self, action: "logOutPressed:", forControlEvents: .TouchUpInside)
        optionsView.addSubview(logOutButton)
        logOutButton.positionBelowItem(termsOfUse, offset: 44)
        logOutButton.pinToSideEdgesOfSuperview()
        logOutButton.sizeToHeight(buttonHeight)
    }
    
    func setupViewController() {
        self.view.backgroundColor = UIColor.whiteColor()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.navigationController?.navigationBar.translucent = false
        
        self.navigationController?.navigationBarHidden = true
    }
    
    func setupScrollView() {
        scrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        scrollView.contentSize = CGSizeMake(self.view.frame.width, 856)
        
        let redView = UIView()
        redView.backgroundColor = Constants.Colors.BounceRed
        redView.frame = CGRectMake(0, -500, self.view.frame.width, 823) // For red at stretch at top
        scrollView.addSubview(redView)
        
        optionsView.backgroundColor = UIColor.whiteColor()
        optionsView.frame = CGRectMake(0, 278, self.view.frame.width, scrollView.contentSize.height - 278)
        scrollView.addSubview(optionsView)
        
        let curve = QuadraticCurve()
        curve.frame = CGRectMake(0, 263, self.view.frame.width, 15)
        scrollView.addSubview(curve)
    }
    
    func renderStatusBarCover() {
        if UIApplication.sharedApplication().statusBarFrame.height <= 20.0 {
            statusBarCover.frame = UIApplication.sharedApplication().statusBarFrame
            statusBarCover.backgroundColor = Constants.Colors.BounceRed
            self.view.addSubview(statusBarCover)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("statusBarFrameChanged:"), name: UIApplicationWillChangeStatusBarFrameNotification, object: nil)
    }

    // MARK: - Button Actions

    /**
     * Presents the user with an alert asking for confirmation, then logs out.
     */
    func logOutPressed(sender: UIButton!) {
        let alertController = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)

        let continueAction = UIAlertAction(title: "Log Out", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            PFUser.logOut()
            self.presentViewController(IntroViewController(), animated: true, completion: nil)
        })
        alertController.addAction(continueAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     * Checks with an alert that the situation is not urgent, then goes to Mail to team@bounceho.me
     */
    func reportIncidentPressed() {
        let alertController = UIAlertController(title: "Are you sure?", message: "If the situation is urgent, please call 911 immediately instead.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let continueAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: "mailto:team@bounceho.me")!)
        })
        alertController.addAction(continueAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     * Composes mail to team@bounceho.me
     */
    func sendEmail() {
        UIApplication.sharedApplication().openURL(NSURL(string: "mailto:team@bounceho.me")!)
    }
}

// MARK: - Utility Classes

/**
 * A title for one of the sections in the Account tab.
 */
private class OptionsTitleLabel: UILabel {
    
    init(text: String) {
        super.init(frame: CGRectMake(0, 0, 0, 0))
        
        self.font = UIFont(name: "AvenirNext-Medium", size: 16)
        self.text = text
        self.textColor = Constants.Colors.BounceRed
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

/**
 * A full screen width grey button, used only in the Account tab.
 */
private class OptionsButton: UIButton {
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    init(text: String, image: UIImage? = nil, buttonHeight: CGFloat = 0.0) {
        super.init(frame: CGRectMake(0, 0, 0, 0))
        
        self.setTitle(text, forState: .Normal)
        self.setTitleColor(UIColor(white: 149/255.0, alpha: 1.0), forState: .Normal)
        self.titleLabel?.textAlignment = .Left
        
        if image == nil {
            self.titleLabel?.pinToLeftEdgeOfSuperview(offset: 15)
        } else {
            self.titleLabel?.pinToLeftEdgeOfSuperview(offset: buttonHeight)
            
            let imageView = UIImageView(image: image)
            imageView.frame = CGRectMake(buttonHeight * 0.25, buttonHeight * 0.25, buttonHeight * 0.5, buttonHeight * 0.5);
            self.addSubview(imageView)
        }
        
        self.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(white: 225.0/255.0, alpha: 1.0).CGColor
        self.backgroundColor = UIColor(white: 237.0/255.0, alpha: 1.0)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                self.backgroundColor = UIColor(white: 200.0/255.0, alpha: 1.0)
            }
            else {
                self.backgroundColor = UIColor(white: 237.0/255.0, alpha: 1.0)
            }
        }
    }
    
}

/**
 * Creates a small quadratic upwards facing curve.
 */
private class QuadraticCurve: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.opaque = false
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, rect)
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        CGContextFillRect(context, rect)
        CGContextMoveToPoint(context, 0, rect.height)
        CGContextAddQuadCurveToPoint(context, rect.width/2.0, 0.0, rect.width, rect.height)
        CGContextAddLineToPoint(context, 0, rect.height)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextFillPath(context)
    }
}
