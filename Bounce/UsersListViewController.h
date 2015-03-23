//
//  UsersListViewController.h
//  bounce
//
//  Created by Shimaa Essam on 3/23/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ParseManager.h"
#import "AppConstant.h"
#import "ChatView.h"

@interface UsersListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;

@end
