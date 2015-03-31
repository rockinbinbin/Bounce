//
//  ParseManager.h
//  ChattingApp
//
//  Created by Shimaa Essam on 3/16/15.
//  Copyright (c) 2015 Shimaa Essam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol ParseManagerLoginDelegate;
@protocol ParseManagerSignupDelegate;
@protocol ParseManagerLoadingGroupsDelegate;
@protocol ParseManagerAddGroupDelegate;

@interface ParseManager : NSObject

@property id<ParseManagerLoginDelegate> loginDelegate;
@property id<ParseManagerSignupDelegate> signupDelegate;
@property id<ParseManagerLoadingGroupsDelegate> loadGroupsdelegate;
@property id<ParseManagerAddGroupDelegate> addGroupdelegate;

+ (ParseManager*) getInstance;
- (void) loginWithName:(NSString *)name andPassword:(NSString*) password;
- (void) signupWithUserName:(NSString *) name andEmail:(NSString*)email andPassword:(NSString*) password;
// Chat message
- (void) createMessageItemForUser:(PFUser *)user WithGroupId:(NSString *) groupId andDescription:(NSString *)description;
// Load chat groups
- (void) loadAllGroups;
// Add Chat group
- (void) addGroup:(NSString*) groupName withLocation:(PFGeoPoint*) location andPrivacy:(NSString*) privacy;
// Request
- (void) createrequestToGroups:(NSArray *) selectedGroups andGender:(NSString *)gender  withinTime:(NSInteger)timeAllocated andInRadius:(NSInteger) radius;
// Append users to group
- (void) addListOfUsers:(NSArray *) users toGroup:(PFObject *) group;
// get request uodates
- (PFObject *) retrieveRequest:(PFObject *) requst;
- (PFObject *) retrieveRequestUpdate:(NSString *) requstId;
// valid receiver
- (BOOL) isValidRequestReceiver:(PFObject*) request;

// nearUsers in group
- (NSInteger) getNearUsersInGroup:(PFObject *) group;
// distance between user and group
- (double) getDistanceToGroup:(PFObject *) group;
// Get User groups
- (NSArray *) getUserGroups;
// Get Groups which currnt user not member at it
- (NSArray *) getCandidateGroupsForCurrentUser;
// get group users
- (NSArray *) getGroupUsers:(PFObject *) group;
// remove group
- (BOOL) removeGroup:(PFObject *) group;
- (NSArray *) getAllUsers;
// Get all groups except created by user
- (NSArray *) getAllGroupsExceptCreatedByUser;
// Add user to group
- (BOOL) addCurrentUserToGroup:(PFObject *) group;
// Remove user from group
- (BOOL) removeUserFromGroup:(PFObject *) group;


@end

@protocol ParseManagerLoginDelegate <NSObject>
- (void) loginSucceed;
- (void) loginFailWithError:(NSError*) error;
@end

@protocol ParseManagerSignupDelegate <NSObject>
- (void) signupSucceed;
- (void) signupFailWithError:(NSError*) error;
@end

@protocol ParseManagerLoadingGroupsDelegate <NSObject>
- (void) didLoadGroups:(NSArray *) groups withError:(NSError *) error;
@end

@protocol ParseManagerAddGroupDelegate <NSObject>
- (void) didAddGroupWithError:(NSError *) error;
@end