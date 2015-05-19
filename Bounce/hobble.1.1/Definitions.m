//
//  Definitions.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/20/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//
//
//#import "Definitions.h"
//
//@implementation Definitions
//
//- (id) init
//{
//    /* first initialize the base class */
//    self = [super init];
//    /* then initialize the instance variables */
//    self.Group = [PFObject objectWithClassName:@"Group"];
//    NSLog(@"here");
//    self.currentUser = [PFUser currentUser];
//   
//    
//    self.groupsRelation = [self.Group relationforKey:ParseGroupRelation]; // this crashes the app. but it shows a relation.
//    
////    self.groupsRelation = [[PFUser currentUser] objectForKey:ParseGroupRelation]; // defines relation as groups in current user. this doesn't crash the app. but it doesn't show a relation.
//    
//    self.UserToGroupsRelation = [[PFUser currentUser] objectForKey:@"UserToGroupsRelation"];
//    
//    
//    //
//    self.groupUsers = [self.Group objectForKey:@"groupUsers"];
//    
//    /* finally return the object */
//    return self;
//}
//
//@end
