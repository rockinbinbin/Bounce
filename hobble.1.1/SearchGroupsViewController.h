//
//  SearchGroupsViewController.h
//  hobble.1.1
//
//  Created by Robin Mehta on 8/21/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface SearchGroupsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSArray *finalResults; // searched group names
@property (nonatomic, strong) NSMutableArray *Names; // all group names
@property (nonatomic, strong) NSArray *groups; // all groups in app
@property (nonatomic, strong) NSMutableArray *MyGroups; // my groups names

- (IBAction)doneButton:(id)sender;

@end
