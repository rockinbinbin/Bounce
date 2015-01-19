//
//  GroupsPlusViewController.h
//  hobble.1.1
//
//  Created by Robin Mehta on 1/19/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
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

@interface GroupsPlusViewController : UIViewController
@property (strong, nonatomic) IBOutlet FUIButton *CreateGroupButton;
@property (strong, nonatomic) IBOutlet FUIButton *SearchGroupsButton;

@end
