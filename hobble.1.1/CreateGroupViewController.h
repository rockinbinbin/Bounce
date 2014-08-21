//
//  CreateGroupViewController.h
//  hobble.1.1
//
//  Created by Robin Mehta on 8/19/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "Definitions.h"

@interface CreateGroupViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (strong, nonatomic) PFUser *currentUser;
//@property (strong, nonatomic) PFRelation *groupsRelation;

//@property (strong, nonatomic) Definitions *predefined;

- (IBAction)Done:(id)sender;

@end
