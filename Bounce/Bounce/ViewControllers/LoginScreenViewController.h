//
//  LoginScreenViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
// THIS IS A TEST
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

@interface LoginScreenViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *LoginButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookLogin;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *facebookIconImageView;
- (IBAction)loginButton:(id)sender;
- (IBAction)facebookLogin:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
@end


