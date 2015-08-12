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

@class RequestsViewController;
@protocol RequestsViewControllerDelegate <NSObject>

@required

- (void) requestsViewControllerDidRequestDismissal:(RequestsViewController *)controller withCompletion:(void (^) ())completion;

@end

@interface RequestsViewController : UIViewController<ParseManagerDelegate, ParseManagerDeleteDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UITableView *requestsTableView;

@property (strong, nonatomic) NSMutableArray *images;
@property (weak, nonatomic) UIView *bottomView;

@end
