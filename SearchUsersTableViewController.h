//
//  SearchUsersTableViewController.h
//  hobble.1.1
//
//  Created by Robin Mehta on 8/10/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FriendsTableViewController.h"
#import "SearchResultsTableViewCell.h"

@interface SearchUsersTableViewController : UITableViewController

@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) FriendsTableViewController *friendclass;
@property (nonatomic, strong) PFRelation *friendsRelation;

@end
