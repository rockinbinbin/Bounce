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
            // Update Request view in home screen
            [self calculateRequestTimeOver];
            
            [self getNumberOfUnReadMessages];
            
            
            NSLog(@"Requist still valid");
            //Update request
            [self updateRequestUsers];
            
        }else{
            // invalidate the request
            [self requestBecomeInvalid];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Request time over
- (void) requestBecomeInvalid
{
    [[ParseManager getInstance] deleteAllRequestData:activeRequest];
    activeRequest = nil;
    [self invalidateCurrentRequest];
    // delete request data
    // update the reply view in home screen
    if ([self.requestManagerDelegate respondsToSelector:@selector(requestTimeOver)]) {
        [self.requestManagerDelegate requestTimeOver];
    }
}
#pragma mark - Update Request Users
- (void) updateRequestUsers
{
    @try {
        PFUser *currentUser = [PFUser currentUser];
        PFGeoPoint *userGeoPoint = currentUser[@"CurrentLocation"];
        NSArray *selectedGroups = [activeRequest objectForKey:PF_REQUEST_SELECTED_GROUPS];
        NSInteger radius = [[activeRequest objectForKey:PF_REQUEST_RADIUS] integerValue];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // get User in the selected groups and within the radius
            NSArray *resultUsers = [self getUsersInSelectedGroups:selectedGroups withGender:[activeRequest objectForKey:PF_GENDER] WithinRequestRadius:radius withSenderName:[currentUser username] andSenderLocation:userGeoPoint];
           
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *oldUsers = [activeRequest objectForKey:@"receivers"];
                NSMutableArray *oldUsersNames = [[NSMutableArray alloc] initWithArray:oldUsers];
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
                    }
                }
                // After finish the remaining users in the oldUserNames ==> are the removed users
                removedUsers = [NSMutableArray arrayWithArray:oldUsersNames];
                // update request record
                if ([addedUsers count] != 0 || [removedUsers count] > 0) {
                    activeRequest[@"receivers"] = resultUsernames;
                    [activeRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        // create group messaging with all users
                        NSString *requestId = activeRequest.objectId;
                        // update request user srelation
                        [self appendUsers:resultUsers toRequestUserRelation:activeRequest];
                        
                        for (PFUser* user in addedUsers) {
                            // send push notification for new users
                            [self sendPushNotificationForUser:user from:[currentUser username]];
                            // creat chat
                            [[ParseManager getInstance] createMessageItemForUser:user WithGroupId:requestId andDescription:@""];
                        }
                        // TODO: Adjust this part
                        [self removeRequestDataForRemovedUser:removedUsers];
                    }];
                } else {
                    NSLog(@"There were no users found.");
                }
            });
        });
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
- (void) removeRequestDataForRemovedUser:(NSArray *)removedUsers
{
    // remove related chatting data
    for (NSString* userName in removedUsers) {
        
        // remove chat if found
        PFQuery *query = [PFUser query];
        [query whereKey:PF_USER_USERNAME equalTo:userName];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count] > 0) {
                [[ParseManager getInstance] deleteUser:[objects objectAtIndex:0] FromRequest:activeRequest];
            }
        }];
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
    
    // first get users in selected groups
    PFUser *currentUser = [PFUser currentUser];
    if (![gender isEqualToString:ALL_GENDER]) {
        gender = [currentUser objectForKey:PF_GENDER];
    }
    PFGeoPoint *userGeoPoint = currentUser[@"CurrentLocation"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // get User in the selected groups and within the radius
        NSArray *resultUsers = [self getUsersInSelectedGroups:selectedGroups withGender:gender WithinRequestRadius:radius withSenderName:[currentUser username] andSenderLocation:userGeoPoint];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Get User names
            NSMutableArray *resultUsernames = [[NSMutableArray alloc] init];
            for (PFUser *user in resultUsers) {
                NSLog(@"%@", user.username);
                [resultUsernames addObject:user.username];
            }
            // Set the request data
            PFObject *request;
            request = [PFObject objectWithClassName:PF_REQUEST_CLASS_NAME];
            request[PF_REQUEST_SENDER] = currentUser.username;
            request[PF_REQUEST_RECEIVER] = resultUsernames;
            request[PF_REQUEST_SELECTED_GROUPS] = selectedGroups;
            request[PF_REQUEST_RADIUS] = [NSNumber numberWithInteger:radius];
            request[PF_REQUEST_TIME_ALLOCATED] = [NSNumber numberWithInteger:timeAllocated];
            NSLog(@"location %@ ", locationManger.location);
            request[PF_REQUEST_LOCATION] = [PFGeoPoint geoPointWithLocation:locationManger.location];
            request[PF_GENDER] = gender;
            [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                // Set the request end date
                request[PF_REQUEST_END_DATE] = [[request createdAt] dateByAddingTimeInterval:(timeAllocated*60)];
                // save the request relations
                [self setRequestGroupRelation:request withGroups:selectedGroups];
                [self appendUsers:resultUsers toRequestUserRelation:request];
                // create group messaging with all users
                NSString *requestId = request.objectId;
                [[ParseManager getInstance] createMessageItemForUser:currentUser WithGroupId:requestId andDescription:@"request"];
                for (PFUser* user in resultUsers) {
                    [[ParseManager getInstance] createMessageItemForUser:user WithGroupId:requestId andDescription:@""];
                    [self sendPushNotificationForUser:user from:[currentUser username]];
                }
                // start request updating
                activeRequest = request;
                // update the home screen view
                self.requestLeftTimeInMinute = timeAllocated;
                if ([self.requestManagerDelegate respondsToSelector:@selector(requestCreated)]) {
                    [self.requestManagerDelegate requestCreated];
                }
                [self startRequestUpdating];
            }];
        });
    });
    
}

#pragma mark - Get Useres in selected groups within radius
- (NSArray*) getUsersInSelectedGroups:(NSArray *)selectedGroups withGender:(NSString*) gender WithinRequestRadius:(NSInteger)radius withSenderName:(NSString *)username andSenderLocation:(PFGeoPoint*) location
{
    @try {
        PFQuery *query = [PFUser query];
        NSMutableArray *queries = [[NSMutableArray alloc] init];
        // go through all groups to find users who are near
        for (NSString *groupName in selectedGroups) {
            PFQuery *query = [PFUser query];
            [query whereKey:@"username" notEqualTo:username];
            if (![gender isEqualToString:ALL_GENDER]) {
                [query whereKey:PF_GENDER equalTo:gender];
            }
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

#pragma mark - Add Object to request user relation
- (void) appendUsers:(NSArray *) users toRequestUserRelation:(PFObject *) request
{
    @try {
        PFRelation *receiversRelation = [request relationForKey:PF_REQUEST_RECEIVERS_RELATION];
        for (PFObject *user in users) {
            [receiversRelation addObject:user];
        }
        [request saveInBackground];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Set the request group relation
- (void) setRequestGroupRelation:(PFObject *) request withGroups:(NSArray *) selectedGroups
{
    @try {
        PFRelation *groupsrelation = [request relationForKey:PF_REQUEST_GROUPS_RELATION];
        // get all groups
        PFQuery *groupsQuery = [PFQuery queryWithClassName:@"Groups"];
        [groupsQuery whereKey:@"groupName" containedIn:selectedGroups];
        [groupsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSArray *groupsObjects = objects;
            for (PFObject *group in groupsObjects) {
                [groupsrelation addObject:group];
            }
            [request saveInBackground];
        }];
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

#pragma mark - End Request
- (void) endRequest
{
    // update request data
    // close the update thread
    // remove the reply view
//    [activeRequest setObject:[NSDate date] forKey:PF_REQUEST_END_DATE];
//    [activeRequest setObject:[NSNumber numberWithBool:YES] forKey:PF_REQUEST_IS_ENDED];
//    [activeRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (!error) {
//            [self invalidateCurrentRequest];
//        }
//        if ([self.requestManagerDelegate respondsToSelector:@selector(didEndRequestWithError:)]) {
//            [self.requestManagerDelegate didEndRequestWithError:error];
//        }
//    }];
    // FIXME: adjust this part to delete the request or mark it ended
    [[ParseManager getInstance] deleteAllRequestData:activeRequest];
    [self invalidateCurrentRequest];
    activeRequest = nil;
    if ([self.requestManagerDelegate respondsToSelector:@selector(didEndRequestWithError:)]) {
        [self.requestManagerDelegate didEndRequestWithError:nil];
    }
}

#pragma mark - Get Number of Unreaded messages
- (void) getNumberOfUnReadMessages
{
    @try {
        PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
        [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
        [query whereKey:PF_MESSAGES_GROUPID equalTo:[activeRequest objectId]];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             NSInteger unReadMessages = [[objects objectAtIndex:0][PF_MESSAGES_COUNTER] intValue];
             self.unReadReplies = unReadMessages;
             if ([self.requestManagerDelegate respondsToSelector:@selector(updateRequestUnreadMessage:)]) {
                 [self.requestManagerDelegate updateRequestUnreadMessage:unReadMessages];
             }
             
         }];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - Get requestTime left
- (void) calculateRequestTimeOver
{
    @try {
//        self.requestLeftTimeInMinute = [[NSDate date] timeIntervalSinceDate:[activeRequest createdAt]]/60;
        self.requestLeftTimeInMinute = [[activeRequest objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue] - ([[NSDate date] timeIntervalSinceDate:[activeRequest createdAt]]/60) ;
        if ([self.requestManagerDelegate respondsToSelector:@selector(updateRequestRemainingTime:)]) {
            [self.requestManagerDelegate updateRequestRemainingTime:self.requestLeftTimeInMinute];
        }
    }
    @catch (NSException *exception) {
        
    }
}
#pragma mark Has Actinve request
- (BOOL) hasActiveRequest
{
    if (activeRequest) {
        return YES;
    }
    return NO;
}
#define ACTIVE_REQUEST_ID @"ActiveRequestId"
#pragma mark - Save active Request Id
- (void) loadActiveRequest
{
    // retreive request data from server
    PFQuery *query = [PFQuery queryWithClassName:PF_REQUEST_CLASS_NAME];
    [query whereKey:PF_REQUEST_SENDER equalTo:[[PFUser currentUser] username]];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // set the default data
        if ([objects count] >0) {
            activeRequest = [objects objectAtIndex:0];
            if (![self isEndDateIsSmallerThanCurrent:[activeRequest objectForKey:PF_REQUEST_END_DATE]]) {
                // remaining time
                [self calculateRequestTimeOver];
                // unreaded message
                [self getNumberOfUnReadMessages];
                [self startRequestUpdating];
            }else{
                activeRequest = nil;
                self.unReadReplies = 0;
                self.requestLeftTimeInMinute = 0;
                //TODO: remove this request with it's chat data
                [[ParseManager getInstance] deleteAllRequestData:[objects objectAtIndex:0]];
            }
        }
    }];
}
@end
