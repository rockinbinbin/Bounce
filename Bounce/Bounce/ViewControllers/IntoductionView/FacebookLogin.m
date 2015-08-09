//
//  FacebookLogin.m
//  bounce
//
//  Created by Robin Mehta on 7/1/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "FacebookLogin.h"
#import "ProgressHUD.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Utility.h"
#import "UIViewController+AMSlideMenu.h"

#import <UIKit/UIKit.h>

#import "AFNetworking.h"
#import "pushnotification.h"
#import "utilities.h"
#import "AppConstant.h"
#import "images.h"
#import "bounce-Swift.h"

@implementation FacebookLogin

- (id)init
{
    IntroViewController *temp = [[IntroViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:temp];
    return [self initWithNavigationController:navController];
}

- (id)initWithNavigationController:(UINavigationController *)navController {
    self = [super init];
    if(self) {
        self.navigationController = navController;
    }
    return self;
}

- (void)facebookLogin {
    [ProgressHUD show:@"Logging in..." Interaction:NO]; // TODO: replace with a nice loading animation
    
    [PFUser logOut];
    
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error) {
         if (user != nil) {
             if (user.isNew) {
                 [self requestFacebook:user];
             }
             else {
                 [self userLoggedIn:user isUserNew:NO];
             }
         }
         else {
             [[Utility getInstance] showAlertWithMessage:@"Please go to Settings > Facebook > Bounce, and allow us to log you in!" andTitle:@"Permission Needed!"];
         }
     }];
}

- (void)requestFacebook:(PFUser *)user{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         if (error == nil) {
             NSDictionary *userData = (NSDictionary *)result;
             [self processFacebook:user UserData:userData];
         }
         else {
             [PFUser logOut];
             [ProgressHUD showError:@"Failed to fetch Facebook user data."];
         }
     }];
}

- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData {
    NSString *link = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage *image = (UIImage *)responseObject;
        if (image.size.width > 140) {
            image = ResizeImage(image, 140, 140);
        }
        PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
             if (error != nil) {
                 [ProgressHUD showError:error.userInfo[@"error"]];
             }
         }];
        
        if (image.size.width > 30) image = ResizeImage(image, 30, 30);
        
        PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
        [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
             if (error != nil) {
                 [ProgressHUD showError:error.userInfo[@"error"]];
             }
         }];
        
        user[PF_USER_EMAILCOPY] = userData[@"email"];
        user[PF_USER_USERNAME] = userData[@"name"];
        user[PF_USER_FULLNAME_KEY] = userData[@"name"];
        user[PF_USER_FULLNAME_LOWER] = [userData[@"name"] lowercaseString];
        user[PF_USER_FACEBOOKID] = userData[@"id"];
        user[PF_USER_PICTURE] = filePicture;
        user[PF_USER_THUMBNAIL] = fileThumbnail;
        user[PF_GENDER] = userData[@"gender"];
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
             if (error == nil) {
                 [self userLoggedIn:user isUserNew:YES];
             }
             else {
                 [PFUser logOut];
                 [ProgressHUD showError:error.userInfo[@"error"]];
             }
         }];
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [PFUser logOut];
         [ProgressHUD showError:@"Failed to fetch Facebook profile picture."];
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)userLoggedIn:(PFUser *)user isUserNew:(BOOL) isNew{
    ParsePushUserAssign();
    if (isNew) {
        [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome %@!", user[PF_USER_FULLNAME]]];
    }
    else {
        [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
    }
    [self navigateToMainScreen];
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    [self navigateToMainScreen];
}

@end
