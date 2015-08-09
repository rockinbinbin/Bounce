//
//  ViewController.swift
//  Scroll View
//
//  Created by Steven on 8/5/15.
//  Copyright (c) 2015 Bounce Labs, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Outlet used in storyboard
    let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        scrollView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        self.view.addSubview(scrollView)
        
        // 1) Create the three views used in the swipe container view
        var AVc : AViewController =  AViewController()
        var BVc : BViewController =  BViewController()
        var CVc : CViewController =  CViewController()

        // 2) Add in each view to the container view hierarchy
        //    Add them in opposite order since the view hieracrhy is a stack
        self.addChildViewController(CVc)
        self.scrollView.addSubview(CVc.view)
        CVc.didMoveToParentViewController(self)

        self.addChildViewController(BVc)
        self.scrollView.addSubview(BVc.view)
        BVc.didMoveToParentViewController(self)
        
        self.addChildViewController(AVc)
        self.scrollView.addSubview(AVc.view)
        AVc.didMoveToParentViewController(self)
        
        
        // 3) Set up the frames of the view controllers to align
        //    with eachother inside the container view
        var adminFrame :CGRect = AVc.view.frame
        adminFrame.origin.x = adminFrame.width
        BVc.view.frame = adminFrame
        
        var BFrame :CGRect = BVc.view.frame
        BFrame.origin.x = 2*BFrame.width
        CVc.view.frame = BFrame
        
        
        // 4) Finally set the size of the scroll view that contains the frames
        var scrollWidth: CGFloat  = 3 * self.view.frame.width
        var scrollHeight: CGFloat  = self.view.frame.size.height
        self.scrollView.contentSize = CGSizeMake(scrollWidth, scrollHeight)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

