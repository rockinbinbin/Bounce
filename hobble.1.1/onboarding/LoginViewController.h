//
//  LoginViewController.h
//  hobble.1.1
//
//  Created by Robin Mehta on 8/7/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlatUIKit.h"
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

#import "AFNetworking.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "ProgressHUD.h"

#import "pushnotification.h"
#import "utilities.h"
#import "AppConstant.h"
#import "images.h"




@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet FUITextField *usernameField;
@property (strong, nonatomic) IBOutlet FUITextField *passwordField;
- (IBAction)loginButton:(id)sender;
@property (strong, nonatomic) IBOutlet FUIButton *LoginButton;
@property (strong, nonatomic) IBOutlet FUIButton *RegisterButton;

- (IBAction)facebookLogin:(id)sender;

@end
