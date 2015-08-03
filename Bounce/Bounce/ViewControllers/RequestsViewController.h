//
//  GroupsListViewController.h
//  ChattingApp
//
//  Created by Shimaa Essam on 3/18/15.
//  Copyright (c) 2015 Shimaa Essam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"
#import "ParseManager.h"

@interface RequestsViewController : UIViewController<ParseManagerDelegate, ParseManagerDeleteDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UITableView *requestsTableView;

@end
