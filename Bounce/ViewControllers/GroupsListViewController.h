//
//  GroupsListViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"
@interface GroupsListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, ParseManagerLoadingGroupsDelegate, ParseManagerGetUserGroups>
@property NSMutableArray* groups;
@property NSMutableArray *nearUsers;
@property NSMutableArray *distanceToUserLocation;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
