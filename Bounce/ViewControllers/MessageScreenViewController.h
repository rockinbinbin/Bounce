//
//  MessageScreenViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
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
#import "NIDropDown.h"
#import "ParseManager.h"
#import "RequestManger.h"

@interface MessageScreenViewController : UIViewController<NIDropDownDelegate, ParseManagerLoadingGroupsDelegate, ParseManagerGetUserGroups, RequestManagerCreateRequestDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *groupGenderSegment;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) NIDropDown *dropDown;
@property (weak, nonatomic) IBOutlet UIButton *distanceSelectButton;
@property (weak, nonatomic) IBOutlet UIButton *durationSelectButton;
- (IBAction)distanceSelectButtonClicked:(id)sender;
- (IBAction)durationSelectButtonClicked:(id)sender;
- (IBAction)genderSegmentClicked:(id)sender;
@property NSString* distance;
@property NSString* duration;
@property BOOL isDistanceSent;
@property BOOL isDataLoaded;
@property NSMutableArray* groups;
@property NSMutableArray *nearUsers;
@property NSMutableArray *distanceToUserLocation;
@property NSMutableArray * selectedCells;
@property (nonatomic, strong) PFObject *Request;
@property (nonatomic, strong) NSMutableArray *selectedGroups;

@property (strong, nonatomic) CLLocationManager *location_manager;
@end
