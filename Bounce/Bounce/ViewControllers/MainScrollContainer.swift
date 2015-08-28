//
//  MainScrollContainer.swift
//  Scroll View
//
//  Created by Steven on 8/5/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

import UIKit

@objc protocol MainScrollContainerDelegate {
    
    /**
     * Enables or disables scrolling on the main scroll container.
     *
     * :param: canScroll True if scrolling is enabled.
     */
    func setScrolling(canScroll: Bool)

    /**
     * Scrolls to the contained view at the index given, starting from 0.
     * Should throw an exception if the scroll index is out of range.
     *
     * :param: index Must be in [0, 1, 2].
     * :param: animated True if the transition should be animated.
     */
    func scrollToViewAtIndex(index: Int, animated: Bool)
}

@objc public class MainScrollContainer: UITabBarController, UITabBarDelegate, MainScrollContainerDelegate {
    private let accountViewController    = AccountViewController()
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
            image = UIImage(named: "Tabs-\(imageName)")
            selectedImage = UIImage(named: "Tabs-\(imageName)-Selected")
            barButtonItem = UIBarButtonItem(image: image, style: .Plain, target: nil, action: nil)
        }
    }
    
    private lazy var homepointsTab: Tab = {
        let navigationController = UINavigationController(rootViewController: self.groupsListViewController)
        let tab = Tab(viewController: navigationController, imageNamed: "Homepoints")
        tab.barButtonItem.target = self
        tab.barButtonItem.action = "selectTabWithBarButtonItem:"
        return tab
    }()
    
    private lazy var tripsTab: Tab = {
        let navigationController = UINavigationController(rootViewController: self.homeScreenViewController)
        let tab = Tab(viewController: navigationController, imageNamed: "Trips")
        tab.barButtonItem.target = self
        tab.barButtonItem.action = "selectTabWithBarButtonItem:"
        return tab
    }()
    
    private lazy var tabs: [Tab] = [self.homepointsTab, self.tripsTab]
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UIApplication.sharedApplication().statusBarHidden = false
        self.navigationController?.navigationBar.translucent = false
        
        let accountViewController = AccountViewController()
        let homeScreenViewController = UINavigationController(rootViewController: HomeScreenViewController())
        let groupsListViewController = UINavigationController(rootViewController: GroupsListViewController())
        
        // Set the delegates
        accountViewController.delegate = self
        
        // These are delegates of UINavigationController instances – get the root VC
        if let homeScreen = homeScreenViewController.viewControllers.first as? HomeScreenViewController {
            homeScreen.delegate = self
        }
        
        if let homepointsScreen = groupsListViewController.viewControllers.first as? GroupsListViewController {
            homepointsScreen.delegate = self
        }
        
        let viewControllers = [groupsListViewController, homeScreenViewController, accountViewController]
        
        self.setViewControllers(viewControllers, animated: true)

        let tabItems = self.tabBar.items as! [UITabBarItem]

        UITabBarItem.appearance().setTitleTextAttributes([
            NSForegroundColorAttributeName : Constants.Colors.BounceRed
            ], forState: UIControlState.Selected)
        
        self.tabBar.tintColor = Constants.Colors.BounceRed
        
        tabItems[0].image = UIImage(named: "Tabs-Homepoints")
        tabItems[0].selectedImage = UIImage(named: "Tabs-Homepoints-Selected")
        tabItems[0].tag = 0
        
        tabItems[1].image = UIImage(named: "Tabs-Trips")
        tabItems[1].selectedImage = UIImage(named: "Tabs-Trips-Selected")
        tabItems[1].tag = 1
        
        tabItems[2].image = UIImage(named: "Tabs-Account")
        tabItems[2].selectedImage = UIImage(named: "Tabs-Account-Selected")
        tabItems[2].tag = 2
        
        tabItems.map { (tabItem : UITabBarItem) -> Void in
            tabItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITabBarDelegate methods
    
    public override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        if item.tag == 2 {
            self.presentViewController(AccountViewController(), animated: true, completion: nil)
        }
    }
    
    // MARK: - MainScrollContainerDelegate methods
    
    func setScrolling(canScroll: Bool) {
        println("setScrolling called")
    }
    
    func scrollToViewAtIndex(index: Int, animated: Bool) {
        println("scrollToViewAtIndex")
//        if index >= 0 && index <= 2 {
//            let destinationFrame = CGRectMake(
//                self.view.frame.size.width * CGFloat(index),
//                0,
//                self.view.frame.size.width,
//                self.view.frame.size.height
//            )
//            
//            self.scrollView.scrollRectToVisible(destinationFrame, animated: animated)
//        } else {
//            println("scrollToViewAtIndex failed: Index out of range")
//        }
    }
}
