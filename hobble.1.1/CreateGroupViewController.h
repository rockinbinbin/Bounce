//
//  CreateGroupViewController.h
//  hobble.1.1
//
//  Created by Robin Mehta on 8/19/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "Definitions.h"
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


@interface CreateGroupViewController : UIViewController

@property (strong, nonatomic) IBOutlet FUITextField *groupNameTextField;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) IBOutlet FUIButton *DoneButton;

- (IBAction)Done:(id)sender;

@end
