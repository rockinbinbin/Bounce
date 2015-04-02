//
//  SelectGroupsTableViewController.h
//  bounce
//
//  Created by Shimaa Essam on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "ParseManager.h"

@interface SelectGroupsTableViewController : UITableViewController<ParseManagerGetUserGroups>

// store in parse:
@property int radius;
@property int timeAllocated;
// create property for location
@property (nonatomic, strong) NSMutableArray *SelectedGroups;

@property (strong, nonatomic) CLLocationManager *location_manager;

@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) PFObject *Request;


@end
