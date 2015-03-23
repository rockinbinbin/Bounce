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

@implementation ParseManager
static ParseManager *parseManager = nil;

+ (ParseManager*) getInstance{
    @try {
        @synchronized(self)
        {
            if (parseManager == nil)
            {
                parseManager = [[ParseManager alloc] init];
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

@end
