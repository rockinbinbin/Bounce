//
//  IntroViewController.swift
//  Bounce
//
//  Created by Steven on 6/18/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

import UIKit
import Parse
import CoreData

public class IntroViewController: UIViewController, UIPageViewControllerDataSource {
    
    // MARK: - Page View Controller Content
    
    var pageViewController : UIPageViewController?
    var pageTitles : Array<String> = ["Meet Bounce.", "Find your homepoints.", "Go out and have fun!", "You’re all set!"]
    var pageImages : Array<String> = ["Intro-Meet-Bounce", "Intro-Houses", "Intro-Glasses", "Intro-People"]
    var pageContent: Array<String> = [
        "Find friends and neighbors to walk home with when out late.",
        "Join trusted community groups, like neighborhoods or dorms.",
        "You'll be matched with others from your homepoints when you're ready to leave.",
        "Time to bounce home with your new crew."
    ]
    var currentIndex : Int = 0
    
    let loginButton = RoundedRectButton(text: "Log in with Facebook")
    
    // MARK: - Overrides
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBackgroundColor()
        self.renderLoginButton()
        self.renderPageViewController()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Element Rendering
    
    func setBackgroundColor() {
        UIApplication.sharedApplication().statusBarHidden = true
        self.view.backgroundColor = Constants.Colors.BounceRed
    }
    
    func renderLoginButton() {
        let width : CGFloat = 0.85 * self.view.frame.width
        let height : CGFloat = 53
        let distanceFromBottom : CGFloat = 50
        
        loginButton.addTarget(self, action: Selector("loginButtonPressed:"), forControlEvents: .TouchUpInside)
        
        let facebookImage = UIImage(named: "Facebook-Rounded-Square")
        let facebookImageView = UIImageView(image: facebookImage)
        facebookImageView.frame = CGRectMake(height * 0.2, height * 0.2, height * 0.6, height * 0.6);
        loginButton.addSubview(facebookImageView)
        
        self.view.addSubview(loginButton)
        
        loginButton.pinToBottomEdgeOfSuperview(offset: 50)
        loginButton.sizeToHeight(53)
        loginButton.pinToSideEdgesOfSuperview(offset: 30)
        
        loginButton.addTarget(self, action: "loginButtonPressed:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(loginButton)
    }
    
    func renderPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController!.dataSource = self
        
        let startingViewController: InstructionView = viewControllerAtIndex(0)!
        let viewControllers: NSArray = [startingViewController]
        pageViewController!.setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: false, completion: nil)
        pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height * 0.8);
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    // MARK: - Page View Controller Functions
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! InstructionView).pageIndex
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        
        return viewControllerAtIndex(index)
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! InstructionView).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if (index == self.pageTitles.count) {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> InstructionView?
    {
        if self.pageTitles.count == 0 || index >= self.pageTitles.count
        {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = InstructionView()
        pageContentViewController.imageFile = pageImages[index]
        pageContentViewController.titleText = pageTitles[index]
        pageContentViewController.bodyText  = pageContent[index]
        pageContentViewController.pageIndex = index
        currentIndex = index
        
        return pageContentViewController
    }
    
    public func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.pageTitles.count
    }
    
    public func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
    // MARK: - Button Actions
    
    func loginButtonPressed(sender: RoundedRectButton!) {
        sender.indicator.startAnimating()
        UIView.animateWithDuration(0.25, animations: {
            sender.titleLabel?.alpha = 0.0
        })
        
        UIView.animateWithDuration(0.25, delay: 0.25, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            sender.indicator.alpha = 1.0
            }, completion: nil)
        
        // FB login
        PFFacebookUtils.logInWithPermissions(["public_profile, user_about_me"], block: {
            (user: PFUser?, error: NSError?) -> Void in
            
            if error != nil {
                self.handleLoginFailed(error!)
                
            } else if user != nil {
                let facebookId = PFUser.currentUser()?.objectForKey("facebook_id") as? String
                
                println("The facebook ID is \(facebookId)")
                
                if let id = facebookId as String! {
                    self.loadProfilePictureOnMainThread(id)
                }
                
                self.loadProfileInfoInBackground()
                
                // New user
                if user!.isNew {
                    self.handleNewUser(user)
                    
                    // Returning user
                } else if let setupComplete: Bool = user!.valueForKey("setupComplete") as? Bool {
                    self.handleReturningUser(user, setupComplete: setupComplete)
                    
                    // Returning user who has not completed setup
                } else {
                    self.presentViewController(StudentStatusViewController(), animated: true, completion: nil)
                }
            }
        })
    }
    
    // MARK: - Login Handlers
    
    func handleLoginFailed(error: NSError) {
        println(error)
        
        let alertController = UIAlertController(
            title: "Uh oh!",
            message: "It seems like the login failed. Check your internet connection and try again.",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        let continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(continueAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func handleNewUser(user: PFUser?) {
        FBRequestConnection.startForMeWithCompletionHandler({ (connection: FBRequestConnection!, result: AnyObject?, error: NSError!) -> Void in
            if error == nil {
                if let id = result?.objectForKey("id") as? String {
                    PFUser.currentUser()?.setObject(id, forKey: "facebook_id")
                    user!.saveInBackgroundWithBlock(nil)
                    self.loadProfilePictureOnMainThread(id)
                }
            } else {
                println(error)
            }
        })
        
        user!.setValue(false, forKey: "setupComplete")
        user!.saveInBackgroundWithBlock(nil)
        self.presentViewController(StudentStatusViewController(), animated: true, completion: nil)
    }
    
    func handleReturningUser(user: PFUser?, setupComplete: Bool) {
        // User has entered the app and completed setup
        if setupComplete {
            user!.setValue(true, forKey: "setupComplete")
            user!.saveInBackgroundWithBlock(nil)
            self.presentViewController(MainScrollContainer(), animated: true, completion: nil)
            
            // User has entered the app and not completed setup
        } else {
            user!.setValue(false, forKey: "setupComplete")
            user!.saveInBackgroundWithBlock(nil)
            self.presentViewController(StudentStatusViewController(), animated: true, completion: nil)
        }
    }
    
    // MARK: - Caching
    
    func loadProfilePictureOnMainThread(id: String!) {
        let pictureURL = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large")
        let profilePicture = UIImage(data: NSData(contentsOfURL: pictureURL!)!)
        
        let imageData = UIImagePNGRepresentation(profilePicture)
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let imagePath = paths.stringByAppendingPathComponent("cachedProfilePicture.png")
        
        if imageData.writeToFile(imagePath, atomically: false) {
            NSUserDefaults.standardUserDefaults().setObject(imagePath, forKey: "imagePath")
        }
    }
    
    func loadProfileInfoInBackground() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity =  NSEntityDescription.entityForName("AccountInfo", inManagedObjectContext: managedContext)
        let accountInfo = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        FBRequestConnection.startForMeWithCompletionHandler({ (connection: FBRequestConnection!, result: AnyObject?, error: NSError!) -> Void in
            if error != nil {
                println(error)
            } else {
                
                // Get user location
                if let locationDict = result?["location"] as? NSDictionary {
                    let locationName = (locationDict["name"] as? String)
                    
                    if let location = locationName as String! {
                        accountInfo.setValue(location, forKey: "location")
                        
                        var error: NSError?
                        if !managedContext.save(&error) {
                            println("Could not save \(error), \(error?.userInfo)")
                        }
                    }
                }
                
                // Get user full name
                if let name = result?["name"] as? String {
                    accountInfo.setValue(name, forKey: "name")
                    
                    var error: NSError?
                    if !managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                } else {
                    println("ERROR: Could not get Facebook name")
                }
            }
        })
        
        // Get number of Facebook friends
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
                        accountInfo.setValue(friendCount, forKey: "friendCount")
                        
                        var error: NSError?
                        if !managedContext.save(&error) {
                            println("Could not save \(error), \(error?.userInfo)")
                        }
                    }
                }
            }
        })
    }
}

