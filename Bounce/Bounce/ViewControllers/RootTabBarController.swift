//
//  RootTabBarController.swift
//  Scroll View
//
//  Created by Steven on 8/5/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

import UIKit

@objc protocol RootTabBarControllerDelegate {
    func setTabBarHidden(hidden: Bool)
}

@objc public class RootTabBarController: UIViewController, RootTabBarControllerDelegate {
    private let homeScreenViewController = HomeScreenViewController()
    private let groupsListViewController = GroupsListViewController()
    
    // MARK: - Tabs
    
    private struct Tab {
        let viewController: UIViewController
        let barButtonItem: UIBarButtonItem
        let image: UIImage?
        let selectedImage: UIImage?
        
        init(viewController: UIViewController, imageNamed imageName: String) {
            self.viewController = viewController
            image = UIImage(named: "Tabs-\(imageName)")?.imageWithRenderingMode(.AlwaysOriginal)
            selectedImage = UIImage(named: "Tabs-\(imageName)-Selected")?.imageWithRenderingMode(.AlwaysOriginal)
            barButtonItem = UIBarButtonItem(image: image, style: .Plain, target: nil, action: nil)
        }
    }
    
    private lazy var homepointsTab: Tab = {
        self.groupsListViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: self.groupsListViewController)
        let tab = Tab(viewController: navigationController, imageNamed: "Homepoints")
        tab.barButtonItem.target = self
        tab.barButtonItem.action = "selectTabWithBarButtonItem:"
        return tab
    }()
    
    private lazy var tripsTab: Tab = {
        self.homeScreenViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: self.homeScreenViewController)
        let tab = Tab(viewController: navigationController, imageNamed: "Trips")
        tab.barButtonItem.target = self
        tab.barButtonItem.action = "selectTabWithBarButtonItem:"
        return tab
    }()
    
    private lazy var tabs: [Tab] = [self.homepointsTab, self.tripsTab]
    
    private lazy var accountBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "Tabs-Account")?.imageWithRenderingMode(.AlwaysOriginal), style: .Plain, target: self, action: "presentSettings:")
    
    private var selectedTab: Tab? {
        didSet {
            if selectedTab?.viewController == oldValue?.viewController {
                return
            }
            if let viewController = oldValue?.viewController {
                viewController.beginAppearanceTransition(false, animated: false)
                oldValue!.barButtonItem.image = oldValue!.image
                viewController.view.removeFromSuperview()
                viewController.endAppearanceTransition()
            }
            if let viewController = selectedTab?.viewController {
                viewController.beginAppearanceTransition(true, animated: false)
                selectedTab!.barButtonItem.image = selectedTab!.selectedImage
                viewController.view.frame = self.view.bounds
                view.addSubview(viewController.view)
                viewController.endAppearanceTransition()
            }
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private var selectedViewController: UIViewController? {
        return selectedTab?.viewController
    }
    
    public class func rootTabBarControllerWithNavigationController() -> UIViewController {
        let navigationController = UINavigationController(rootViewController: RootTabBarController())
        navigationController.navigationBarHidden = true
        navigationController.toolbarHidden = false
        return navigationController
    }
    
    @objc private func selectTabWithBarButtonItem(barButtonItem: UIBarButtonItem) {
        selectedTab = first(tabs) { $0.barButtonItem == barButtonItem }
    }
    
    @objc private func presentSettings(sender: UIBarButtonItem) {
        let accountViewController = AccountViewController()
        let navigationController = UINavigationController(rootViewController: accountViewController)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismissSettings")
        doneButton.tintColor = UIColor.whiteColor()
        
        let attributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 19)!]

        doneButton.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        accountViewController.navigationItem.rightBarButtonItem = doneButton

        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    @objc private func dismissSettings() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    public override func loadView() {
        super.loadView()

        each(tabs.map { $0.viewController }) {
            $0.willMoveToParentViewController(self)
            self.addChildViewController($0)
            $0.didMoveToParentViewController(self)
        }
        
        selectTabWithBarButtonItem(tripsTab.barButtonItem)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.navigationBar.translucent = false
        
        let flexibleSpacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let sideSpacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        sideSpacer.width = 30

        self.setToolbarItems({
                return [sideSpacer] + flatMap(self.tabs) { [$0.barButtonItem, flexibleSpacer] } + [self.accountBarButtonItem, sideSpacer]
            }(), animated: false)
    }
    
    public override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return selectedViewController
    }
    
    public override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return selectedViewController
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc public func setTabBarHidden(hidden: Bool) {
        self.navigationController?.toolbarHidden = hidden
    }
}
