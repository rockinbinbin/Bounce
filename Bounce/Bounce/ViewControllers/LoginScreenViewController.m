//
//  LoginScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "LoginScreenViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Utility.h"
#import "SlideMenuViewController.h"
#import "UIViewController+AMSlideMenu.h"

@interface LoginScreenViewController ()

@end

@implementation LoginScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.LoginButton.backgroundColor = LIGHT_BLUE_COLOR;
    self.facebookLogin.backgroundColor = [UIColor colorWithRed:81.0/250.0 green:117.0/250.0 blue:195.0/250.0 alpha:1.0];
    self.view.backgroundColor = BounceRed;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self disableSlidePanGestureForLeftMenu];
}

// i want this function to execute each time (to bypass login if already logged in)
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupReturnButton];
    // hides keyboard when user hits background
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
}

- (void) hideKeyboard // when user hits background
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void) facebookClicked{
    [self facebookLogin:nil];
}

- (BOOL) textFieldShouldReturn: (UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/// Sets up the done button on keyboard to be blue.
- (void)setupReturnButton {
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
    [self.usernameField setReturnKeyType:UIReturnKeyNext];
    [self.passwordField setReturnKeyType:UIReturnKeyDone];
}

#pragma MARK - Button Action
- (IBAction)loginButton:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0) {
        [[Utility getInstance] showAlertWithMessage:@"Make sure you enter a username and password!" andTitle:@"Oops!"];
    }
    else {
        [[Utility getInstance] showProgressHudWithMessage:@"Login ..."];
        MAKE_A_WEAKSELF;
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            [[Utility getInstance] hideProgressHud];
            if (error) {
                [[Utility getInstance] showAlertWithMessage:[error.userInfo objectForKey:@"error"] andTitle:@"Sorry!"];
            }
            else {
                [weakSelf navigateToMainScreen];
                ParsePushUserAssign();
                [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (IBAction)facebookLogin:(id)sender {
    NSLog(@"facebookLogin");
    [ProgressHUD show:@"Logging in..." Interaction:NO];
    
    [PFUser logOut];
    
    MAKE_A_WEAKSELF;
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
     {
         if (user != nil)
         {
             if (user.isNew) // Not signed in facebook
                 //                 if (user[PF_USER_FACEBOOKID] == nil) // Not signed in facebook
             {
                 [weakSelf requestFacebook:user];
             }
             else {
                 [weakSelf userLoggedIn:user isUserNew:NO]; // Signed in facebook
             }
         }
         else {
             [ProgressHUD showError:error.userInfo[@"error"]];
             [[Utility getInstance] showAlertWithMessage:@"Please go to Settings > Facebook > Bounce, and allow us to log you in!" andTitle:@"Permission Needed!"];
         }
     }];
}



- (void)requestFacebook:(PFUser *)user{
    NSLog(@"requestFacebook");
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

- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData{
    NSLog(@"processFacebook");
    NSString *link = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        UIImage *image = (UIImage *)responseObject;
        if (image.size.width > 140) {
            
            image = ResizeImage(image, 140, 140);
        }
        PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) {
                 [ProgressHUD showError:error.userInfo[@"error"]];
             }
         }];
        if (image.size.width > 30) image = ResizeImage(image, 30, 30);
        PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
        [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil)
             {
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
        
        MAKE_A_WEAKSELF;
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error == nil)
             {
                 [weakSelf userLoggedIn:user isUserNew:YES];
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
    
    NSLog(@"userLoggedIn");
    ParsePushUserAssign();
    if (isNew) {
        [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome %@!", user[PF_USER_FULLNAME]]];
    }
    else{
        [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
    }
    [self navigateToMainScreen];
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    [self navigateToMainScreen];
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