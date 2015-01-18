//
//  NewMessageViewController.h
//  Hobble
//
//  Created by Robin Mehta on 1/17/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddGroupsTableViewController.h"

@interface NewMessageViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *TimeAllocated;
@property (strong, nonatomic) IBOutlet UITextField *Radius;
- (IBAction)AddGroupsButton:(id)sender;

@end
