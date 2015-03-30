//
//  RequestManger.m
//  ChattingApp
//
//  Created by Shimaa Essam on 3/29/15.
//  Copyright (c) 2015 Shimaa Essam. All rights reserved.
//

#import "RequestManger.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "ParseManager.h"
#import "Constants.h"

@implementation RequestManger
{
    PFObject *activeRequest;
    NSTimer *startRequestTimer;
    
    
}
CLLocationManager *locationManger;
static RequestManger *sharedRequestManger = nil;

+ (RequestManger*) getInstance{
    @try {
        @synchronized(self)
        {
            if (sharedRequestManger == nil)
            {
                sharedRequestManger = [[RequestManger alloc] init];
            }
        }
        return sharedRequestManger;
    }
    @catch (NSException *exception) {
    }
}

#define REQUEST_UPDATE_REPEATINTERVAL 10
#pragma mark - Start Request update
- (void) startRequestUpdating
{
    if (!startRequestTimer) {
        startRequestTimer = [NSTimer scheduledTimerWithTimeInterval:REQUEST_UPDATE_REPEATINTERVAL target:self selector:@selector(updatRequest) userInfo:nil repeats:YES];
    }
}

#pragma mark - Update Request
- (void) updatRequest
{
    @try {
        // if request time over == >invalidate request
        // else get new users whic near from me
        // remove the far users
        NSDate *endDate = [[activeRequest createdAt] dateByAddingTimeInterval:[[activeRequest objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue] * 60];
        if (![self isEndDateIsSmallerThanCurrent:endDate]) {
            //Update request
            NSLog(@"Requist still valid");
            
            PFUser *currentUser = [PFUser currentUser];
            PFGeoPoint *userGeoPoint = currentUser[@"CurrentLocation"];
            NSArray *oldUsers = [activeRequest objectForKey:@"receivers"];
            NSArray *selectedGroups = [activeRequest objectForKey:PF_REQUEST_SELECTED_GROUPS];
            NSInteger radius = [[activeRequest objectForKey:PF_REQUEST_RADIUS] integerValue];
            NSMutableArray *oldUsersNames = [[NSMutableArray alloc] initWithArray:oldUsers];
            
            // go through all groups to find users who are near
            NSArray *resultUsers = [self getUsersInSelectedGroups:selectedGroups WithinRequestRadius:radius withSenderName:[currentUser username] andSenderLocation:userGeoPoint];
            
            NSMutableArray *resultUsernames = [[NSMutableArray alloc] init];
            NSMutableArray *addedUsers = [[NSMutableArray alloc] init];
            NSMutableArray *removedUsers = [[NSMutableArray alloc] init];
            for (PFUser *user in resultUsers) {
                [resultUsernames addObject:user.username];
                NSLog(@"%@", user.username);
                if (![oldUsersNames containsObject:user.username]) {
                    [addedUsers addObject:user];
                }else{
                    // remove this user from list
                    [oldUsersNames removeObject:user.username];
                    [removedUsers addObject:user];
                }
            }
            // update request record
            if ([addedUsers count] != 0 || [removedUsers count] > 0) {
                // NSLog(@"%@", resultUsers[0][@"DeviceID"]);
                PFObject *request;
                activeRequest[@"receivers"] = resultUsernames;
                [activeRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    // create group messaging with all users
                    NSString *requestId = request.objectId;
                    
                    
                    for (PFUser* user in addedUsers) {
                        // send push notification for new users
                        // creat chat
                        [self sendPushNotificationForUser:user from:[currentUser username]];
                        [[ParseManager getInstance] createMessageItemForUser:user WithGroupId:requestId andDescription:@""];
                    }
//                    for (PFUser* user in removedUsers) {
//                        // remove chat if found
//                        //                    [[ParseManager getInstance] createMessageItemForUser:user WithGroupId:requestId andDescription:@""];
//                    }
                }];
                
            } else {
                NSLog(@"There were no users found.");
            }
        }else{
            // invalidate the request
            [self invalidateCurrentRequest];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Compare dates
- (BOOL)isEndDateIsSmallerThanCurrent:(NSDate *)checkEndDate
{
    NSDate* enddate = checkEndDate;
    NSDate* currentdate = [NSDate date];
    NSTimeInterval distanceBetweenDates = [enddate timeIntervalSinceDate:currentdate];
    
    if (distanceBetweenDates == 0)
        return YES;
    else if (distanceBetweenDates < 0)
        return YES;
    else
        return NO;
}

#pragma mark - Invalidate Request
- (void) invalidateCurrentRequest
{
    if (startRequestTimer) {
        [startRequestTimer invalidate];
        startRequestTimer = nil;
    }
}

#pragma mark - Request
- (void) createrequestToGroups:(NSArray *) selectedGroups andGender:(NSString *)gender  withinTime:(NSInteger)timeAllocated andInRadius:(NSInteger) radius{
    
    PFUser *currentUser = [PFUser currentUser];
    PFGeoPoint *userGeoPoint = currentUser[@"CurrentLocation"];
    
    NSArray *resultUsers = [self getUsersInSelectedGroups:selectedGroups WithinRequestRadius:radius withSenderName:[currentUser username] andSenderLocation:userGeoPoint];
    NSMutableArray *resultUsernames = [[NSMutableArray alloc] init];
    for (PFUser *user in resultUsers) {
        NSLog(@"%@", user.username);
        [resultUsernames addObject:user.username];
    }
    
    if ([resultUsers count] != 0) {
        // NSLog(@"%@", resultUsers[0][@"DeviceID"]);
        PFObject *request;
        request = [PFObject objectWithClassName:PF_REQUET_CLASS_NAME];
        request[PF_REQUEST_SENDER] = [PFUser currentUser].username;
        request[PF_REQUEST_RECEIVER] = resultUsernames;
        
        request[PF_REQUEST_SELECTED_GROUPS] = selectedGroups;
        request[PF_REQUEST_RADIUS] = [NSNumber numberWithInteger:radius];
        request[PF_REQUEST_TIME_ALLOCATED] = [NSNumber numberWithInteger:timeAllocated];
        NSLog(@"location %@ ", locationManger.location);
        request[PF_REQUEST_LOCATION] = [PFGeoPoint geoPointWithLocation:locationManger.location];
        
        // add request relations
        // TODO: If we will depend on relation we will use relation code
        PFRelation *groupsrelation = [request relationForKey:PF_REQUEST_GROUPS_RELATION];
        PFRelation *receiversRelation = [request relationForKey:PF_REQUEST_RECEIVERS_RELATION];
        // get all groups
        PFQuery *groupsQuery = [PFQuery queryWithClassName:@"Groups"];
        [groupsQuery whereKey:@"groupName" containedIn:selectedGroups];
        NSArray *groupsObjects = [groupsQuery findObjects];
        for (PFObject *group in groupsObjects) {
            [groupsrelation addObject:group];
        }
        for (PFObject *user in resultUsers) {
            [receiversRelation addObject:user];
        }
        
        [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            // create group messaging with all users
            NSString *requestId = request.objectId;
            [[ParseManager getInstance] createMessageItemForUser:[PFUser currentUser] WithGroupId:requestId andDescription:@"request"];
            
            for (PFUser* user in resultUsers) {
                
                [[ParseManager getInstance] createMessageItemForUser:user WithGroupId:requestId andDescription:@""];
                [self sendPushNotificationForUser:user from:[currentUser username]];
            }
        }];
        // start request updating
        activeRequest = request;
        [self startRequestUpdating];
    } else {
        NSLog(@"There were no users found.");
    }
}

//- (void) createrequestToGroups:(NSArray *) selectedGroups andGender:(NSString *)gender  withinTime:(NSInteger)timeAllocated andInRadius:(NSInteger) radius{
//
//    PFQuery *query = [PFUser query];
//    PFUser *currentUser = [PFUser currentUser];
//    PFGeoPoint *userGeoPoint = currentUser[@"CurrentLocation"];
//
//    NSMutableArray *queries = [[NSMutableArray alloc] init];
//
//    // go through all groups to find users who are near
//    for (NSString *groupName in selectedGroups) {
//        PFQuery *query = [PFUser query];
//        [query whereKey:@"username" notEqualTo:currentUser.username];
//        [query whereKey:@"ArrayOfGroups" equalTo:groupName];
//        [query whereKey:@"CurrentLocation" nearGeoPoint:userGeoPoint withinMiles:radius];
//        [queries addObject:query];
//    }
//
//    query = [PFQuery orQueryWithSubqueries:queries];
//    NSArray *resultUsers = [query findObjects];
//
//    NSMutableArray *resultUsernames = [[NSMutableArray alloc] init];
//
//    for (PFUser *user in resultUsers) {
//        NSLog(@"%@", user.username);
//        [resultUsernames addObject:user.username];
//    }
//
//    if ([resultUsers count] != 0) {
//        // NSLog(@"%@", resultUsers[0][@"DeviceID"]);
//        PFObject *request;
//        request = [PFObject objectWithClassName:@"Requests"];
//        request[@"Sender"] = [PFUser currentUser].username;
//        request[@"receivers"] = resultUsernames;
//
//
//        request[@"RequestedGroups"] = selectedGroups;
//        request[@"Radius"] = [NSNumber numberWithInteger:radius];
//        request[@"TimeAllocated"] = [NSNumber numberWithInteger:timeAllocated];
//        NSLog(@"location %@ ", locationManger.location);
//        request[@"Location"] = [PFGeoPoint geoPointWithLocation:locationManger.location];
//
//        // add request relations
//        PFRelation *groupsrelation = [request relationForKey:PF_REQUEST_GROUPS_RELATION];
//        PFRelation *receiversRelation = [request relationForKey:PF_REQUEST_RECEIVERS_RELATION];
//
//        // get all groups
//        PFQuery *groupsQuery = [PFQuery queryWithClassName:@"Groups"];
//        [groupsQuery whereKey:@"groupName" containedIn:selectedGroups];
//        NSArray *groupsObjects = [groupsQuery findObjects];
//        for (PFObject *group in groupsObjects) {
//            [groupsrelation addObject:group];
//        }
//
//        for (PFObject *user in resultUsers) {
//            [receiversRelation addObject:user];
//        }
//
//        [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
//            // create group messaging with all users
//            NSString *requestId = request.objectId;
//            [[ParseManager getInstance] createMessageItemForUser:[PFUser currentUser] WithGroupId:requestId andDescription:@"request"];
//
//            for (PFUser* user in resultUsers) {
//
//                [[ParseManager getInstance] createMessageItemForUser:user WithGroupId:requestId andDescription:@""];
//
//                PFQuery *queryInstallation = [PFInstallation query];
//                [queryInstallation whereKey:PF_INSTALLATION_USER equalTo:user];
//
//                PFPush *push = [[PFPush alloc] init];
//                [push setQuery:queryInstallation];
//                [push setMessage:[NSString stringWithFormat:@"%@ send request to you", currentUser.username]];
//                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//                 {
//                     if (error != nil)
//                     {
//                         NSLog(@"SendPushNotification send error.");
//                     }
//                 }];
//            }
//            // send push notification for all user in this request chat
//
//
//
//
//
//        }];
//
//
//        // start request updating
//        activeRequest = request;
//        [self startRequestUpdating];
//
//    } else {
//        NSLog(@"There were no users found.");
//    }
//
//
//    //    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//
//}
#pragma mark - Get Useres in selected groups within radius
- (NSArray*) getUsersInSelectedGroups:(NSArray *)selectedGroups WithinRequestRadius:(NSInteger)radius withSenderName:(NSString *)username andSenderLocation:(PFGeoPoint*) location
{
    @try {
        PFQuery *query = [PFUser query];
        NSMutableArray *queries = [[NSMutableArray alloc] init];
        // go through all groups to find users who are near
        for (NSString *groupName in selectedGroups) {
            PFQuery *query = [PFUser query];
            [query whereKey:@"username" notEqualTo:username];
            [query whereKey:@"ArrayOfGroups" equalTo:groupName];
            [query whereKey:@"CurrentLocation" nearGeoPoint:location withinMiles:radius];
            [queries addObject:query];
        }
        query = [PFQuery orQueryWithSubqueries:queries];
        NSArray *resultUsers = [query findObjects];
        
        return resultUsers;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - Add chat to request receiver
- (void) sendPushNotificationForUser:(PFUser *) user from:(NSString *) senderName
{
    @try {
        PFQuery *queryInstallation = [PFInstallation query];
        [queryInstallation whereKey:PF_INSTALLATION_USER equalTo:user];
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:queryInstallation];
        [push setMessage:[NSString stringWithFormat:@"%@ send request to you", senderName]];
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil)
             {
                 NSLog(@"SendPushNotification send error.");
             }
         }];
    }
    @catch (NSException *exception) {
    }
}
#pragma mark - remove message chat of delete users

@end
