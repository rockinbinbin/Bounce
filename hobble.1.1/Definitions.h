//
//  Definitions.h
//  hobble.1.1
//
//  Created by Robin Mehta on 8/20/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface Definitions : NSObject

@property (nonatomic, strong) PFObject *Group;
@property (nonatomic, strong) PFRelation *groupsRelation;
@property (nonatomic, strong) PFRelation *UserToGroupsRelation;
@property (nonatomic, strong) PFRelation *groupUsers;
@property (nonatomic, strong) PFUser *currentUser;

- (id) init;

@end
