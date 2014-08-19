//
//  GroupsTableViewController.h
//  hobble.1.1
//
//  Created by Robin Mehta on 8/11/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface GroupsTableViewController : UITableViewController

@property (nonatomic, strong) PFRelation *groupsRelation;
@property (nonatomic, strong) NSMutableArray *groups; // store here after query
@property (nonatomic, strong) PFUser *currentUser;

-(void)userPressedDone; // as of now, just refreshes table view. move all relation/ stuff here?

@end
