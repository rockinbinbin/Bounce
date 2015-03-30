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

@implementation ParseManager
static ParseManager *parseManager = nil;
CLLocationManager *locationManger;
+ (ParseManager*) getInstance{
    @try {
        @synchronized(self)
        {
            if (parseManager == nil)
            {
                parseManager = [[ParseManager alloc] init];
                locationManger = [[CLLocationManager alloc] init];
            }
        }
        return parseManager;
    }
    @catch (NSException *exception) {
    }
}

#pragma mark - login
- (void) loginWithName:(NSString *)name andPassword:(NSString*) password{
    [PFUser logInWithUsernameInBackground:name password:password  block:^(PFUser *user, NSError *error){
        if(!error){
            NSLog(@"No error");
            if([PFUser currentUser]){
                NSLog(@"User is login successfully");
                [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                [[PFInstallation currentInstallation] setObject:@"true" forKey:@"State"];
                [[PFInstallation currentInstallation] saveEventually];
                // call login succeed
                if ([self.loginDelegate respondsToSelector:@selector(loginSucceed)]) {
                    [self.loginDelegate loginSucceed];
                }
            }else{
                NSLog(@"Login isn't performed successfully");
                if ([self.loginDelegate respondsToSelector:@selector(loginFailWithError:)]) {
                    [self.loginDelegate loginFailWithError:error];
                }
            }
        }else{
            //show error message in alert dialog
            if ([self.loginDelegate respondsToSelector:@selector(loginFailWithError:)]) {
                [self.loginDelegate loginFailWithError:error];
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
        [signUpUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Signup is performed successfully");
                [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                [[PFInstallation currentInstallation] setObject:@"true" forKey:@"State"];
                [[PFInstallation currentInstallation] saveEventually];
                // call sign up succeed delegate method
                if ([self.signupDelegate respondsToSelector:@selector(signupSucceed)]) {
                    [self.signupDelegate signupSucceed];
                }
            } else {
                if ([self.signupDelegate respondsToSelector:@selector(signupFailWithError:)]) {
                    [self.signupDelegate signupFailWithError:error];
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
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if ([self.loadGroupsdelegate respondsToSelector:@selector(didLoadGroups:withError:)]) {
             [self.loadGroupsdelegate didLoadGroups:objects withError:error];
         }
     }];
}


#pragma mark - Add Chat Group
- (void) addChatGroup:(NSString*) groupName{
    PFObject *object = [PFObject objectWithClassName:PF_GROUPS_CLASS_NAME];
    object[PF_GROUPS_NAME] = groupName;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if ([self.addGroupdelegate respondsToSelector:@selector(didAddGroupWithError:)]) {
             [self.addGroupdelegate didAddGroupWithError:error];
         }
     }];
}


#pragma mark - Request
- (void) createrequestToGroups:(NSArray *) selectedGroups andGender:(NSString *)gender  withinTime:(NSInteger)timeAllocated andInRadius:(NSInteger) radius{
    
    PFQuery *query = [PFUser query];
    PFUser *currentUser = [PFUser currentUser];
    PFGeoPoint *userGeoPoint = currentUser[@"CurrentLocation"];
    
    NSMutableArray *queries = [[NSMutableArray alloc] init];
    
    // go through all groups to find users who are near
    for (NSString *groupName in selectedGroups) {
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" notEqualTo:currentUser.username];
        [query whereKey:@"ArrayOfGroups" equalTo:groupName];
        [query whereKey:@"CurrentLocation" nearGeoPoint:userGeoPoint withinMiles:radius];
        [queries addObject:query];
    }
    
    query = [PFQuery orQueryWithSubqueries:queries];
    NSArray *resultUsers = [query findObjects];
    
    NSMutableArray *resultUsernames = [[NSMutableArray alloc] init];
    
    for (PFUser *user in resultUsers) {
        NSLog(@"%@", user.username);
        [resultUsernames addObject:user.username];
    }
    
    if ([resultUsers count] != 0) {
        // NSLog(@"%@", resultUsers[0][@"DeviceID"]);
        PFObject *request;
        request = [PFObject objectWithClassName:@"Requests"];
        request[@"Sender"] = [PFUser currentUser].username;
        request[@"receivers"] = resultUsernames;
        
        
        request[@"RequestedGroups"] = selectedGroups;
        request[@"Radius"] = [NSNumber numberWithInteger:radius];
        request[@"TimeAllocated"] = [NSNumber numberWithInteger:timeAllocated];
        NSLog(@"location %@ ", locationManger.location);
        request[@"Location"] = [PFGeoPoint geoPointWithLocation:locationManger.location];
        [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            // create group messaging with all users
            NSString *requestId = request.objectId;
            [[ParseManager getInstance] createMessageItemForUser:[PFUser currentUser] WithGroupId:requestId andDescription:@"request"];
            
            for (PFUser* user in resultUsers) {
                // send him push notification
                // send push notification for all user in this request chat
                PFQuery *query = [PFUser query];
                [query whereKey:PF_USER_OBJECTID equalTo:user.objectId];
                //            [query whereKey:PF_MESSAGES_USER notEqualTo:[PFUser currentUser]];
                //            [query includeKey:PF_MESSAGES_USER];
                //            [query setLimit:1000];
                
                PFQuery *queryInstallation = [PFInstallation query];
                [queryInstallation whereKey:PF_INSTALLATION_USER equalTo:user];
                
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:queryInstallation];
                [push setMessage:[NSString stringWithFormat:@"%@ send request to you", currentUser.username]];
                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (error != nil)
                     {
                         NSLog(@"SendPushNotification send error.");
                     }
                 }];
                
                [[ParseManager getInstance] createMessageItemForUser:user WithGroupId:requestId andDescription:@""];
            }
            

        }];
        
//        [self sendPushNotificationFormUser:currentUser.username toUsers:resultUsernames];
//        // SET DELEGATE HERE
//        if (delegate != nil) {
//            NSLog(@"DELEGATE IS NOT NIL");
//            [self didSelectMultipleUsers:resultUsernames];
//        }
        
        
        
        
    } else {
        NSLog(@"There were no users found.");
    }
    
    
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}
- (void) sendPushNotificationFormUser:(NSString*)senderName toUsers:(NSArray *) users
{
    PFQuery *query = [PFUser query];
//    [query whereKey:PF_MESSAGES_GROUPID equalTo:groupId];
    // Finds scores from any of Jonathan, Dario, or Shawn
//    NSArray *names = @[@"Jonathan Walsh",
//                       @"Dario Wunsch",
//                       @"Shawn Simon"];
    [query whereKey:PF_USER_USERNAME containedIn:users];
//    [query whereKey:PF_MESSAGES_USER notEqualTo:[PFUser currentUser]];
//    [query includeKey:PF_MESSAGES_USER];
    [query setLimit:1000];
    
    
    PFQuery *queryInstallation = [PFInstallation query];
    [queryInstallation whereKey:PF_INSTALLATION_USER containedIn:users];
//    NSArray *installation = [queryInstallation findObjects];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:queryInstallation];
    [push setMessage:senderName];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             NSLog(@"SendPushNotification send error.");
         }
     }];
}

#pragma mark - Add Users to group
- (void) addListOfUsers:(NSArray *) users toGroup:(PFObject *) group{
    // get the userRelation of the group
    // then append users to this relation
    PFQuery *query = [PFUser query];
    [query whereKey:PF_USER_USERNAME containedIn:users];
    [query setLimit:1000];
    
    NSArray *usersArray = [query findObjects];
    PFRelation *relation = [group relationForKey:@"groupUsers"];
    for (PFUser *user in  usersArray) {
        [relation addObject:user];
    }
    
    [group saveInBackground];
    
}

@end