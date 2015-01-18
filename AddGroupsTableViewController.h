//
//  AddGroupsTableViewController.h
//  Hobble
//
//  Created by Robin Mehta on 1/17/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddGroupsTableViewController : UITableViewController

// store in parse:
@property int radius;
@property int timeAllocated;
// create property for location
@property (nonatomic, strong) NSMutableArray *SelectedGroups;


@property (nonatomic, strong) NSMutableArray *groups;

@end
