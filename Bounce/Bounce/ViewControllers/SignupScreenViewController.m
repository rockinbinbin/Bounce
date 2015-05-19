//
//  SignupScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "SignupScreenViewController.h"
#import "GenderScreenViewController.h"
#import <Parse/Parse.h>
#import "HomeScreenViewController.h"
#import "Utility.h"
#import "AppConstant.h"
#import "UIViewController+AMSlideMenu.h"
#import "IntroLoginScreenViewController.h"
#import "SlideMenuViewController.h"
@interface SignupScreenViewController ()

@end

@implementation SignupScreenViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    self.RegisterButton.backgroundColor = LIGHT_BLUE_COLOR;
    self.view.backgroundColor = DEFAULT_COLOR;
    self.facebookLogin.backgroundColor = [UIColor colorWithRed:81.0/250.0 green:117.0/250.0 blue:195.0/250.0 alpha:1.0];
    // hides keyboard when user hits background
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    [self disableSlidePanGestureForLeftMenu];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillDisappear:animated];
}

- (void) hideKeyboard{ // when user hits background
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void) facebookClicked{
    [self facebookSignin:nil];
}
// hides keyboard when user clicks return
- (BOOL) textFieldShouldReturn: (UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signupButton:(id)sender {
    
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([username length] == 0 || [password length] == 0){
        [[Utility getInstance] showAlertWithMessage:@"Make sure you enter a username, password!" andTitle:@"Oops!"];
    }
//    else if (![username hasPrefix:@"@"]) {
//        [[Utility getInstance] showAlertWithMessage:@"User handles must begin with an "@" symbol." andTitle:@"Oops!"];
//    }
    else{
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Check name availability..."];
            PFQuery *query = [PFUser query];
            [query whereKey:@"username" equalTo:username];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [[Utility getInstance] hideProgressHud];
                if (objects.count) {
                    NSLog(@"NOT UNIQUE USERNAME"); // write alert to try a different username
                    [[Utility getInstance] showAlertWithMessage:@"This user handle seems to be taken. Please choose another!" andTitle:@"Oops!"];
                }
                else {
                    
                    PFUser *signUpUser = [PFUser user];
                    signUpUser.username = username;
                    //                signUpUser.email = password;
                    signUpUser.password = password;
                    
                    GenderScreenViewController* genderScreenViewController = [[GenderScreenViewController alloc] initWithNibName:@"GenderScreenViewController" bundle:nil];
                    genderScreenViewController.currentUser = signUpUser;
                    [self.navigationController pushViewController:genderScreenViewController animated:YES];
                }
            }];
            
        }
    }
}

- (IBAction)facebookSignin:(id)sender {
    [ProgressHUD show:@"Signing in..." Interaction:NO];
    
    [PFUser logOut];
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
     {
         if (user != nil)
         {
             if (user[PF_USER_FACEBOOKID] == nil) // Not signed in facebook
             {
                 [self requestFacebook:user];
             }
             else {
                 [self userLoggedIn:user isUserNew:NO]; // Signed in facebook
             }
         }
         else {
             [ProgressHUD showError:error.userInfo[@"error"]];
            [[Utility getInstance] showAlertWithMessage:@"Please go to Settings > Facebook > Bounce, and allow us to log you in!" andTitle:@"Permission Needed!"];
         }
     }];
}

- (void)requestFacebook:(PFUser *)user   {
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         if (error == nil)
         {
             
             NSDictionary *userData = (NSDictionary *)result;
             [self processFacebook:user UserData:userData];
         }
         else
         {
             [PFUser logOut];
             [ProgressHUD showError:@"Failed to fetch Facebook user data."];
         }
     }];
}

- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData   {
    NSString *link = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         UIImage *image = (UIImage *)responseObject;
         if (image.size.width > 140) image = ResizeImage(image, 140, 140);
         PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
         [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil) [ProgressHUD showError:error.userInfo[@"error"]];
          }];
         if (image.size.width > 30) image = ResizeImage(image, 30, 30);
         PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
         [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil) [ProgressHUD showError:error.userInfo[@"error"]];
          }];
         user[PF_USER_EMAILCOPY] = userData[@"email"];
         user[PF_USER_FULLNAME] = userData[@"name"];
         user[PF_USER_FULLNAME_KEY] = userData[@"name"];
         user[PF_USER_FULLNAME_LOWER] = [userData[@"name"] lowercaseString];
         user[PF_USER_FACEBOOKID] = userData[@"id"];
         user[PF_USER_PICTURE] = filePicture;
         user[PF_USER_THUMBNAIL] = fileThumbnail;
         user[PF_GENDER] = userData[@"gender"];
         [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error == nil)
              {
                  [self userLoggedIn:user isUserNew:YES];
              }
              else
              {
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
    else{
        [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
    }
    [self navigateToMainScreen];
}

// Logged-in user experience -- THIS DOESN'T WORK?
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    HomeScreenViewController* homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
    [self.navigationController pushViewController:homeScreenViewController animated:YES];
}


- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigate to Home screem
- (void) navigateToMainScreen
{
    @try {
        SlideMenuViewController* mainViewController = [[SlideMenuViewController alloc] init];
        [self.navigationController pushViewController:mainViewController animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

@end

