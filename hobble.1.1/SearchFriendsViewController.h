//
//  SearchFriendsViewController.h
//  hobble.1.1
//
//  Created by Robin Mehta on 8/18/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FriendsTableViewController.h"

@interface SearchFriendsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSArray *searchResults; // all users in app
@property (nonatomic, strong) FriendsTableViewController *friendclass;
@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSArray *finalResults; // searched users

@end
