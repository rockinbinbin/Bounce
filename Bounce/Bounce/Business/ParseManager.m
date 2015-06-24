//
//  ParseManager.m
//  ChattingApp
//
//  Created by Shimaa Essam on 3/16/15.
//  Copyright (c) 2015 Shimaa Essam. All rights reserved.
//

#import "ParseManager.h"
#import "Utility.h"
#import "AppConstant.h"
#import <MapKit/MapKit.h>
#import "Constants.h"

@implementation ParseManager
static ParseManager *parseManager = nil;
CLLocationManager *locationManger;
PFUser *currentUser;
+ (ParseManager*) getInstance{
    @try {
        @synchronized(self)
        {
            if (parseManager == nil)
            {
                parseManager = [[ParseManager alloc] init];
                locationManger = [[CLLocationManager alloc] init];
                
                currentUser = [PFUser currentUser];
            }
        }
        return parseManager;
    }
    @catch (NSException *exception) {
    }
}

#pragma mark - login
- (void) loginWithName:(NSString *)name andPassword:(NSString*) password {
    MAKE_A_WEAKSELF;
    [PFUser logInWithUsernameInBackground:name password:password  block:^(PFUser *user, NSError *error){
        if(!error){
            NSLog(@"No error");
            if([PFUser currentUser]){
                NSLog(@"User is login successfully");
                [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                [[PFInstallation currentInstallation] setObject:@"true" forKey:@"State"];
                [[PFInstallation currentInstallation] saveEventually];
                // call login succeed
                if ([weakSelf.loginDelegate respondsToSelector:@selector(loginSucceed)]) {
                    [weakSelf.loginDelegate loginSucceed];
                }
            }else{
                NSLog(@"Login isn't performed successfully");
                if ([weakSelf.loginDelegate respondsToSelector:@selector(loginFailWithError:)]) {
                    [weakSelf.loginDelegate loginFailWithError:error];
                }
            }
        }else{
            //show error message in alert dialog
            if ([weakSelf.loginDelegate respondsToSelector:@selector(loginFailWithError:)]) {
                [weakSelf.loginDelegate loginFailWithError:error];
            }
        }
    }];
}

#pragma mark - Signup
- (void) signupWithUserName:(NSString *) name andEmail:(NSString*)email andPassword:(NSString*) password{
    @try {
        PFUser *signUpUser = [PFUser user];
        signUpUser.username = name;
        signUpUser.email = email;
        signUpUser.password = password;
        
        MAKE_A_WEAKSELF;
        [signUpUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Signup is performed successfully");
                [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                [[PFInstallation currentInstallation] setObject:@"true" forKey:@"State"];
                [[PFInstallation currentInstallation] saveEventually];
                // call sign up succeed delegate method
                if ([weakSelf.signupDelegate respondsToSelector:@selector(signupSucceed)]) {
                    [weakSelf.signupDelegate signupSucceed];
                }
            } else {
                if ([weakSelf.signupDelegate respondsToSelector:@selector(signupFailWithError:)]) {
                    [weakSelf.signupDelegate signupFailWithError:error];
                }
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Create Chat message channel
- (void) createMessageItemForUser:(PFUser *)user WithGroupId:(NSString *) groupId andDescription:(NSString *)description
{
    PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
    [query whereKey:PF_MESSAGES_USER equalTo:user];
    [query whereKey:PF_MESSAGES_GROUPID equalTo:groupId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             if ([objects count] == 0)
             {
                 PFObject *message = [PFObject objectWithClassName:PF_MESSAGES_CLASS_NAME];
                 message[PF_MESSAGES_USER] = user;
                 message[PF_MESSAGES_GROUPID] = groupId;
                 message[PF_MESSAGES_DESCRIPTION] = description;
                 message[PF_MESSAGES_LASTUSER] = [PFUser currentUser];
                 message[PF_MESSAGES_LASTMESSAGE] = @"";
                 message[PF_MESSAGES_COUNTER] = @0;
                 message[PF_MESSAGES_UPDATEDACTION] = [NSDate date];
                 [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (error != nil) NSLog(@"CreateMessageItem save error.");
                  }];
             }
         }
         else NSLog(@"CreateMessageItem query error.");
     }];
}

#pragma mark - Load Chat Groups
- (void) loadAllGroups{
    PFQuery *query = [PFQuery queryWithClassName:PF_GROUPS_CLASS_NAME];
    MAKE_A_WEAKSELF;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([weakSelf.loadGroupsdelegate respondsToSelector:@selector(didLoadGroups:withError:)]) {
             [weakSelf.loadGroupsdelegate didLoadGroups:objects withError:error];
         }
     }];
}
#pragma mark - Groups
#pragma mark  Add Group
- (void) addGroup:(NSString*) groupName withLocation:(PFGeoPoint*) location andPrivacy:(NSString*) privacy {
    PFObject *object = [PFObject objectWithClassName:PF_GROUPS_CLASS_NAME];
    object[PF_GROUPS_NAME] = groupName;
    object[PF_GROUP_LOCATION] = location;
    object[PF_GROUP_PRIVACY] = privacy;
    object[PF_GROUP_OWNER] = [PFUser currentUser];
    MAKE_A_WEAKSELF;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         // Added the user to GroupUsers relation
         PFRelation *usersRelation = [object relationForKey:PF_GROUP_Users_RELATION];
         [usersRelation addObject:[PFUser currentUser]];
         [object saveInBackground];
         if ([weakSelf.addGroupdelegate respondsToSelector:@selector(didAddGroupWithError:)]) {
             [weakSelf.addGroupdelegate didAddGroupWithError:error];
         }
     }];
}

- (void) addGroup:(NSString*) groupName withArrayOfUser:(NSArray *)users withLocation:(PFGeoPoint*) location andPrivacy:(NSString*) privacy {
    PFObject *object = [PFObject objectWithClassName:PF_GROUPS_CLASS_NAME];
    object[PF_GROUPS_NAME] = groupName;
    object[PF_GROUP_LOCATION] = location;
    object[PF_GROUP_PRIVACY] = privacy;
    object[PF_GROUP_OWNER] = [PFUser currentUser];
    MAKE_A_WEAKSELF;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         // Added the user to GroupUsers relation
         PFRelation *usersRelation = [object relationForKey:PF_GROUP_Users_RELATION];
         for (PFUser *user in users) {
             [usersRelation addObject:user];
         }
         [object saveInBackground];
         if ([weakSelf.addGroupdelegate respondsToSelector:@selector(didAddGroupWithError:)]) {
             [weakSelf.addGroupdelegate didAddGroupWithError:error];
         }
     }];
}

#pragma mark - Group name
- (void) isGroupNameExist:(NSString *) name
{
    PFQuery *query = [PFQuery queryWithClassName:PF_GROUPS_CLASS_NAME];
    [query whereKey:PF_GROUPS_NAME equalTo:name];
    MAKE_A_WEAKSELF;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([weakSelf.updateGroupDelegate respondsToSelector:@selector(groupNameExist:)]) {
                [weakSelf.updateGroupDelegate groupNameExist:([objects count] > 0)];
            }
        }else{
            if ([weakSelf.updateGroupDelegate respondsToSelector:@selector(didFailWithError:)]) {
                [weakSelf.updateGroupDelegate didFailWithError:error];
            }
        }
    }];
}

#pragma mark  Add Users to group
- (void) addListOfUsers:(NSArray *) users toGroup:(PFObject *) group{
    // get the userRelation of the group
    // then append users to this relation
    PFRelation *relation = [group relationForKey:@"groupUsers"];
    for (PFUser *user in  users) {
        [relation addObject:user];
    }
    MAKE_A_WEAKSELF;
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if ([weakSelf.updateGroupDelegate respondsToSelector:@selector(didUpdateGroupData:)]) {
            [weakSelf.updateGroupDelegate didUpdateGroupData:succeeded];
        }
    }];
}

- (void) addListOfUsers:(NSArray *) users toGroup:(PFObject *) group andRemove:(NSArray *) removedUsers
{
    // get the userRelation of the group
    // then append users to this relation
    PFRelation *relation = [group relationForKey:PF_GROUP_Users_RELATION];
    for (PFUser *user in  users) {
        [relation addObject:user];
    }
    
    for (PFUser *user in  removedUsers) {
        [relation removeObject:user];
    }
    MAKE_A_WEAKSELF;
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if ([weakSelf.updateGroupDelegate respondsToSelector:@selector(didUpdateGroupData:)]) {
            [weakSelf.updateGroupDelegate didUpdateGroupData:succeeded];
        }
    }];
}

#pragma mark Group Users
- (void) getGroupUsers:(PFObject *) group
{
    PFRelation *usersRelation = [group relationForKey:PF_GROUP_Users_RELATION];
    PFQuery *query = [usersRelation query];
    [query whereKey:OBJECT_ID notEqualTo:[[PFUser currentUser] objectId]];
    MAKE_A_WEAKSELF;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            if ([weakSelf.delegate respondsToSelector:@selector(didFailWithError:)]) {
                [weakSelf.delegate didFailWithError:error];
            }
        }else{
            if ([weakSelf.delegate respondsToSelector:@selector(didloadAllObjects:)]) {
                [weakSelf.delegate didloadAllObjects:objects];
            }
        }
    }];
}

#pragma mark  Get Groups of user
- (void) getUserGroups
{
    @try {
        PFQuery *query = [PFQuery queryWithClassName:PF_GROUPS_CLASS_NAME];
        [query whereKey:PF_GROUP_Users_RELATION equalTo:[PFUser currentUser]];
        [query includeKey:PF_GROUP_OWNER];
        
        MAKE_A_WEAKSELF;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([weakSelf.getUserGroupsdelegate respondsToSelector:@selector(didLoadUserGroups:WithError:)]) {
                [weakSelf.getUserGroupsdelegate didLoadUserGroups:objects WithError:error];
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

- (void) getCandidateGroupsForCurrentUser
{
    @try {
        PFQuery *query = [PFQuery queryWithClassName:PF_GROUPS_CLASS_NAME];
        [query whereKey:PF_GROUP_Users_RELATION notEqualTo:[PFUser currentUser]];
        [query whereKey:PF_GROUP_PRIVACY equalTo:PUBLIC_GROUP];
        [query whereKey:PF_GROUP_LOCATION nearGeoPoint:[[PFUser currentUser] objectForKey:PF_USER_LOCATION]];
        [query setLimit:10];
        MAKE_A_WEAKSELF;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([weakSelf.loadGroupsdelegate respondsToSelector:@selector(didLoadGroups:withError:)]) {
                [weakSelf.loadGroupsdelegate didLoadGroups:objects withError:error];
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark  Remove Group
- (void) removeGroup:(PFObject *) group
{
    @try {
        MAKE_A_WEAKSELF;
        [group deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if ([weakSelf.deleteDelegate respondsToSelector:@selector(didDeleteObject:)]) {
                [weakSelf.deleteDelegate didDeleteObject:succeeded];
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

- (void) deleteGroup:(PFObject *) group
{
    @try {
        if ([[[group objectForKey:PF_GROUP_OWNER] username] isEqualToString:[[PFUser currentUser] username]]) {
            [self removeGroup:group];
        }else{
            [self deleteCurrentUserFromGroup:group];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark  Out user from group
- (void) removeUserFromGroup:(PFObject *) group
{
    @try {
        PFUser *currentUser = [PFUser currentUser];
        PFRelation *relation = [group relationForKey:PF_GROUP_Users_RELATION];
        [relation removeObject:currentUser];
        MAKE_A_WEAKSELF;
        [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if ([weakSelf.updateGroupDelegate respondsToSelector:@selector(didRemoveUserFromGroup:)]) {
                [weakSelf.updateGroupDelegate didRemoveUserFromGroup:succeeded];
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

- (void) deleteCurrentUserFromGroup:(PFObject *) group
{
    @try {
        PFUser *currentUser = [PFUser currentUser];
        PFRelation *relation = [group relationForKey:PF_GROUP_Users_RELATION];
        [relation removeObject:currentUser];
        MAKE_A_WEAKSELF;
        [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if ([weakSelf.deleteDelegate respondsToSelector:@selector(didDeleteObject:)]) {
                [weakSelf.deleteDelegate didDeleteObject:succeeded];
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - Get all Groups in the system except created by user
- (NSArray *) getAllGroupsExceptCreatedByUser
{
    @try {
        PFQuery *query = [PFQuery queryWithClassName:PF_GROUPS_CLASS_NAME];
        [query whereKey:PF_GROUP_OWNER notEqualTo:[PFUser currentUser]];
        //        [query includeKey:PF_GROUP_OWNER];
        NSArray *groups = [query findObjects];
        return groups;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - Add User to group
- (void) addCurrentUserToGroup:(PFObject *) group
{
    @try {
        // Add relation
        PFUser *currentUser = [PFUser currentUser];
        PFRelation *relation = [group relationForKey:PF_GROUP_Users_RELATION];
        [relation addObject:currentUser];
        MAKE_A_WEAKSELF;
        [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if ([weakSelf.updateGroupDelegate respondsToSelector:@selector(didAddUserToGroup:)]) {
                [weakSelf.updateGroupDelegate didAddUserToGroup:succeeded];
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Get request
- (PFObject *) retrieveRequestUpdate:(NSString *) requstId
{
    PFQuery *query = [PFQuery queryWithClassName:PF_REQUEST_CLASS_NAME];
    [query whereKey:@"objectId" equalTo:requstId];
    PFObject *result = [query getFirstObject];
    return result;
}
- (BOOL) isValidRequestReceiver:(PFObject*) request
{
    NSArray *requestReceiver = [request objectForKey:PF_REQUEST_RECEIVER];
    if ([requestReceiver containsObject:[[PFUser currentUser] username]]) {
        return YES;
    }else if ([[request objectForKey:PF_REQUEST_SENDER] isEqualToString:[[PFUser currentUser] username]]){
        return YES;
    }
    return NO;
}

#pragma mark - Get Group Users near current User
- (NSInteger) getNearUsersNumberInGroup:(PFObject *) group
{
    // User's location
    PFGeoPoint *userGeoPoint = [[PFUser currentUser] objectForKey:PF_USER_LOCATION];
    PFRelation *userRelation = [group relationForKey:PF_GROUP_Users_RELATION];
    PFQuery *query = [userRelation query];
    [query whereKey:PF_USER_USERNAME notEqualTo:[[PFUser currentUser] username]];
    [query whereKey:PF_USER_LOCATION nearGeoPoint:userGeoPoint withinMiles:K_NEAR_DISTANCE];
   return [query countObjects];
}

#pragma mark - Get Users
- (void) getAllUsers{
    PFQuery *query = [PFUser query];
    [query whereKey:PF_USER_USERNAME notEqualTo:[[PFUser currentUser] username]];
    MAKE_A_WEAKSELF;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            if ([weakSelf.delegate respondsToSelector:@selector(didFailWithError:)]) {
                [weakSelf.delegate didFailWithError:error];
            }
        } else {
            if ([weakSelf.delegate respondsToSelector:@selector(didloadAllObjects:)]) {
                [weakSelf.delegate didloadAllObjects:objects];
            }
        }
    }];
}
#pragma mark - Distance to HomePoint (Group)
- (double) getDistanceToGroup:(PFObject *) group
{
    PFGeoPoint *userGeoPoint = [[PFUser currentUser] objectForKey:PF_USER_LOCATION];
    PFGeoPoint *groupGeoPoint = [group objectForKey:PF_GROUP_LOCATION];
    if (!groupGeoPoint) {
       groupGeoPoint = [PFGeoPoint  geoPointWithLatitude:31.0 longitude:29.0] ;
    }
//    return [userGeoPoint distanceInMilesTo:groupGeoPoint];
    return ([userGeoPoint distanceInKilometersTo:groupGeoPoint] * FEET_IN_KILOMETER);
}

#pragma mark - Set the current user
- (void) setCurrentUser:(PFUser *) user
{
    currentUser = user;
}

#pragma mark - IS There Alogged user
- (BOOL) isThereLoggedUser
{
    if ([PFUser currentUser]) {
       return YES;
    }
    return NO;
}

#pragma mark - Number of valid Requests
- (void) getNumberOfValidRequests
{
    // load requests if the user is sender or receiver
    PFQuery *query1 = [PFQuery queryWithClassName:PF_REQUEST_CLASS_NAME];
    [query1 whereKey:PF_REQUEST_SENDER equalTo:[[PFUser currentUser] username]];
    PFQuery *query2 = [PFQuery queryWithClassName:PF_REQUEST_CLASS_NAME];
    [query2 whereKey:@"receivers" equalTo:[[PFUser currentUser] username]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:query1, query2, nil]];
    [query whereKey:PF_REQUEST_END_DATE greaterThan:[NSDate date]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         // fire notification to update the request numbers
         NSDictionary* dict = [NSDictionary dictionaryWithObject:
                               [NSNumber numberWithInteger:[objects count]]
                                                          forKey:CHAT];
         [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_NUMBER_POST_NOTIFICATION object:nil userInfo:dict];

     }];
}

#pragma mark - Load all User requests
- (void) getUserRequests
{
    @try {
        PFQuery *query1 = [PFQuery queryWithClassName:PF_REQUEST_CLASS_NAME];
        [query1 whereKey:PF_REQUEST_SENDER equalTo:[[PFUser currentUser] username]];
        PFQuery *query2 = [PFQuery queryWithClassName:PF_REQUEST_CLASS_NAME];
        [query2 whereKey:PF_REQUEST_RECEIVER equalTo:[[PFUser currentUser] username]];
        PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:query1, query2, nil]];
        [query orderByDescending:PF_CREATED_AT];
        MAKE_A_WEAKSELF;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error) {
                 if ([weakSelf.delegate respondsToSelector:@selector(didFailWithError:)]) {
                     [weakSelf.delegate didFailWithError:error];
                 }
             } else {
                 if ([weakSelf.delegate respondsToSelector:@selector(didloadAllObjects:)]) {
                     [weakSelf.delegate didloadAllObjects:objects];
                 }
             }
         }];
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}

#pragma mark - Delet request
/*
 Delete the request if the current user is the request sender
 Else delete the curren user from the request
 then Delete the related data to the request like the chat data
 */
-(void) deleteRequest:(PFObject *) request
{
    @try {
        NSString *requestId = [request objectId];
        if ([[request objectForKey:PF_REQUEST_SENDER] isEqualToString:[[PFUser currentUser] username]]) {
            MAKE_A_WEAKSELF;
            [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if ([weakSelf.deleteDelegate respondsToSelector:@selector(didDeleteObject:)]) {
                    [weakSelf.deleteDelegate didDeleteObject:succeeded];
                }
                [weakSelf deleteChatDataRelatedToRequestId:requestId ForExactUser:nil];
            }];
        } else {
            // remove the current user from the receivers
            [self deleteUser:[PFUser currentUser] FromRequest:request];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
- (void) deleteAllRequestData:(PFObject *) request
{
    @try {
        NSString *requestId = [request objectId];
        MAKE_A_WEAKSELF;
        [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [weakSelf deleteChatDataRelatedToRequestId:requestId ForExactUser:nil];
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - Detete User from request
// called from request screens
- (void) deleteUser:(PFUser *) user FromRequest:(PFObject *) request
{
    @try {
        NSString *requestId = [request objectId];
       // delete user from the receiver relation
        PFRelation *receiversRelation = [request relationForKey:PF_REQUEST_RECEIVERS_RELATION];
        [receiversRelation removeObject:user];
       // delete him from reveiver
        [request removeObject:[user username] forKey:PF_REQUEST_RECEIVER];
        
        MAKE_A_WEAKSELF;
        [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if ([[user username] isEqualToString:[[PFUser currentUser] username]]) {
                // this called from requests screen  and must return to it
                if ([weakSelf.deleteDelegate respondsToSelector:@selector(didDeleteObject:)]) {
                    [weakSelf.deleteDelegate didDeleteObject:succeeded];
                }
            }
            // delete message
            // delete chat messages
            [weakSelf deleteChatDataRelatedToRequestId:requestId ForExactUser:user];
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
- (void) deleteChatDataRelatedToRequestId:(NSString *) requestId ForExactUser:(PFUser *) user
{
    @try {
        // delete chat object
        PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
        [query whereKey:PF_MESSAGES_GROUPID equalTo:requestId];
        if (user) {
            [query whereKey:PF_MESSAGES_USER equalTo:user];
        }
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 if (objects > 0) {
                     for (int i = 0; i<[objects count]; i++) {
                         [[objects objectAtIndex:i] deleteInBackground];
                     }
                 }
             }
             else NSLog(@"CreateMessageItem query error.");
         }];
        // delete chat messages
        PFQuery *cahtMessagesQuery = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
        [cahtMessagesQuery whereKey:PF_CHAT_GROUPID equalTo:requestId];
        if (user) {
            [cahtMessagesQuery whereKey:PF_CHAT_USER equalTo:user];
        }
        [cahtMessagesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if (objects > 0) {
                for (int i = 0; i<[objects count]; i++) {
                    [[objects objectAtIndex:i] deleteInBackground];
                }
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - Get all useres that don't join group
- (void) getCandidateUsersForGroup:(PFObject *) group
{
    @try {
        PFRelation *usersRelation = [group relationForKey:PF_GROUP_Users_RELATION];
        PFQuery *groupUsersQuery = [usersRelation query];
        PFQuery *query = [PFUser query];
        [query whereKey:OBJECT_ID  doesNotMatchKey:OBJECT_ID inQuery:groupUsersQuery];
        MAKE_A_WEAKSELF;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if ([weakSelf.loadNewUsers respondsToSelector:@selector(didloadNewUsers:WithError:)]) {
                    [weakSelf.loadNewUsers didloadNewUsers:objects WithError:error];
                }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}
@end
