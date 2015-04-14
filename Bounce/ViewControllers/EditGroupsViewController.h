//
//  EditGroupsViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "ParseManager.h"

@interface EditGroupsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, ParseManagerDeleteDelegate>
@property NSMutableArray* groups;
@property NSMutableArray *nearUsers;
@property NSMutableArray *distanceToUserLocation;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
