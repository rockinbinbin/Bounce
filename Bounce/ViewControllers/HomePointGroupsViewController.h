//
//  HomePointGroupsViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePointGroupsViewController : UIViewController
@property NSArray *groupUsers;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
