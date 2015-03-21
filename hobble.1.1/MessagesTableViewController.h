//
//  MessagesTableViewController.h
//  bounce
//
//  Created by Robin Mehta on 3/9/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddGroupsTableViewController.h"

@interface MessagesTableViewController : UITableViewController <SelectMultipleDelegate>

- (void)loadMessages;

@end
