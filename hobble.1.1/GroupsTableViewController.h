//
//  GroupsTableViewController.h
//  hobble.1.1
//
//  Created by Robin Mehta on 8/11/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "Definitions.h"
#import "ParseManager.h"

@interface GroupsTableViewController : UITableViewController <ParseManagerLoadingGroupsDelegate>

@property (nonatomic, strong) NSMutableArray *groups; // store here after query

@end
