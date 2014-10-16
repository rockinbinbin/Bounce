//
//  FriendsTableViewController.h
//  hobble.1.1
//
//  Created by Robin Mehta on 8/8/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface FriendsTableViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) PFUser *currentUser;


- (BOOL)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

//-(void)userPressedDone;

@end
