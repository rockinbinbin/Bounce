//
//  HomePointGroupsViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ParseManager.h"

@interface AddGroupUsersViewController : UIViewController<ParseManagerAddGroupDelegate, ParseManagerUpdateGroupDelegate, UITableViewDataSource, UITableViewDelegate>

@property NSArray *groupUsers;
@property NSMutableArray *userChecked; // array of selected users
@property (nonatomic, assign) PFGeoPoint * groupLocation;

@property (strong, nonatomic) NSString* groupName;
@property BOOL editGroup;
@property NSArray *originalGroupUsers;
@property NSArray *remainingUsers;
@property PFObject *updatedGroup;

@property (weak, nonatomic) UITableView *tableView;

@end
