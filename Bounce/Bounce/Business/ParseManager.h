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
@protocol ParseManagerGetUserGroups;
@protocol ParseManagerUpdateGroupDelegate;
@protocol ParseManagerFailureDelegate;
@protocol ParseManagerDelegate;
@protocol ParseManagerDeleteDelegate;
@protocol ParseManagerLoadNewUsers;

@interface ParseManager : NSObject

@property id<ParseManagerLoginDelegate> loginDelegate;
@property id<ParseManagerSignupDelegate> signupDelegate;
@property id<ParseManagerLoadingGroupsDelegate> loadGroupsdelegate;
@property id<ParseManagerAddGroupDelegate> addGroupdelegate;
@property id<ParseManagerGetUserGroups> getUserGroupsdelegate;
@property id<ParseManagerUpdateGroupDelegate> updateGroupDelegate;
@property id<ParseManagerFailureDelegate> failureDelegaet;
@property id<ParseManagerDelegate> delegate;
@property id<ParseManagerDeleteDelegate> deleteDelegate;
@property id<ParseManagerLoadNewUsers> loadNewUsers;

+ (ParseManager*) getInstance;
// Chat message
- (void) createMessageItemForUser:(PFUser *)user WithGroupId:(NSString *) groupId andDescription:(NSString *)description;
// Groups
- (NSArray *) getAllGroupsExceptCreatedByUser;
- (void) isGroupNameExist:(NSString *) name;
- (void) addGroup:(NSString*) groupName withLocation:(PFGeoPoint*) location andPrivacy:(NSString*) privacy;
- (void) loadAllGroups;
- (void) addGroup:(NSString*) groupName withArrayOfUser:(NSArray *)users withLocation:(PFGeoPoint*) location andPrivacy:(NSString*) privacy;
// get request uodates
- (PFObject *) retrieveRequestUpdate:(NSString *) requstId;
// valid receiver
- (BOOL) isValidRequestReceiver:(PFObject*) request;
// nearUsers in group

// COMMENTED OUT TO SILENCE WARNING
//- (NSInteger) getNearUsersInGroup:(PFObject *) group;
// distance between user and group

- (double) getDistanceToGroup:(PFObject *) group;
// Get User groups
- (void) getUserGroups;
// Get Groups which currnt user not member at it
- (void) getCandidateGroupsForCurrentUser;
// remove group
- (void) removeGroup:(PFObject *) group;
- (void) deleteGroup:(PFObject *) group;
// Useres Operations
- (void) getAllUsers;
// check if there is a user logged in
- (BOOL) isThereLoggedUser;
// GET VALID REQUEST NUMBER
- (void) getNumberOfValidRequests;
// Get user requests
- (void) getUserRequests;
// Delete Request
-(void) deleteRequest:(PFObject *) request;
- (void) deleteUser:(PFUser *) user FromRequest:(PFObject *) request;
- (void) deleteAllRequestData:(PFObject *) request;
- (void) deleteChatDataRelatedToRequestId:(NSString *) requestId ForExactUser:(PFUser *) user;
// Users in group
- (void) getCandidateUsersForGroup:(PFObject *) group;
- (void) getGroupUsers:(PFObject *) group;
- (void) addListOfUsers:(NSArray *) users toGroup:(PFObject *) group andRemove:(NSArray *) removedUsers;
- (NSInteger) getNearUsersNumberInGroup:(PFObject *) group;
- (void) addCurrentUserToGroup:(PFObject *) group;
- (void) removeUserFromGroup:(PFObject *) group;
- (void) addListOfUsers:(NSArray *) users toGroup:(PFObject *) group;

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

@protocol ParseManagerGetUserGroups <NSObject>
- (void) didLoadUserGroups:(NSArray *)groups WithError:(NSError *) error;
@end

@protocol ParseManagerUpdateGroupDelegate<NSObject>

@optional
- (void) didUpdateGroupData:(BOOL) succeed;
- (void) didAddUserToGroup:(BOOL) succeed;
- (void) didRemoveUserFromGroup:(BOOL) succeed;
- (void) groupNameExist:(BOOL) exist;
- (void) didFailWithError:(NSError *)error;

@end

@protocol ParseManagerFailureDelegate <NSObject>
- (void) didFailWithError:(NSError *) error;
@end

@protocol ParseManagerDelegate <NSObject>
- (void) didloadAllObjects:(NSArray *) objects;
- (void) didFailWithError:(NSError *) error;
@end

@protocol ParseManagerDeleteDelegate <NSObject>
- (void) didDeleteObject:(BOOL) succeeded;
@end

@protocol ParseManagerLoadNewUsers <NSObject>
- (void) didloadNewUsers:(NSArray *)users WithError:(NSError *) error;
@end
