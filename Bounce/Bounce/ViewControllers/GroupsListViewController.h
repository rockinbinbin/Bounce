//
//  GroupsListViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"

@interface GroupsListViewController : UIViewController<
    UITableViewDelegate,
    UITableViewDataSource,
    ParseManagerLoadingGroupsDelegate,
    ParseManagerGetUserGroups,
    ParseManagerDeleteDelegate,
    ParseManagerDelegate,
    ParseManagerGetTentativeUsers
>

@property NSMutableArray* groups;
@property NSMutableArray *nearUsers;
@property NSMutableArray *distanceToUserLocation;
@property (weak, nonatomic) UITableView *tableView;
@property NSMutableArray *homepointImages;

// A MainScrollContainer delegate
@property (strong, nonatomic) id delegate;

@end
