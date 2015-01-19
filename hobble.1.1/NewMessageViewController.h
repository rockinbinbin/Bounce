//
//  NewMessageViewController.h
//  Hobble
//
//  Created by Robin Mehta on 1/17/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddGroupsTableViewController.h"
#import "UIColor+FlatUI.h"
#import "UISlider+FlatUI.h"
#import "UIStepper+FlatUI.h"
#import "UITabBar+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "FUIButton.h"
#import "FUISwitch.h"
#import "UIFont+FlatUI.h"
#import "FUIAlertView.h"
#import "UIBarButtonItem+FlatUI.h"
#import "UIProgressView+FlatUI.h"
#import "FUISegmentedControl.h"
#import "UIPopoverController+FlatUI.h"


@interface NewMessageViewController : UIViewController
@property (strong, nonatomic) IBOutlet FUITextField *TimeAllocated;
@property (strong, nonatomic) IBOutlet FUITextField *Radius;
@property (strong, nonatomic) IBOutlet FUIButton *AddGroupsButton;

@end
