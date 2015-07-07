//
//  FacebookLogin.h
//  bounce
//
//  Created by Robin Mehta on 7/1/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface FacebookLogin : NSObject

@property (nonatomic, weak) UINavigationController *navigationController;

- (id)initWithNavigationController:(UINavigationController *)navController;
- (void)facebookLogin;
- (void)requestFacebook:(PFUser *)user;
- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData;
- (void)userLoggedIn:(PFUser *)user isUserNew:(BOOL) isNew;
- (void) navigateToMainScreen;



@end
