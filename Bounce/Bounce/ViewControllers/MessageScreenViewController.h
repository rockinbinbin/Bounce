//
//  MessageScreenViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NIDropDown.h"
#import "ParseManager.h"
#import "RequestManger.h"

@interface MessageScreenViewController : UIViewController<ParseManagerLoadingGroupsDelegate, ParseManagerGetUserGroups, RequestManagerCreateRequestDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *groupGenderSegment;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
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
@property (weak, nonatomic) NSString *genderMatching;
@property (nonatomic) float timeAllocated;

@property (strong, nonatomic) CLLocationManager *location_manager;
@end
