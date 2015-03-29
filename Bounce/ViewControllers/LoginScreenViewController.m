//
//  LoginScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "LoginScreenViewController.h"
#import <Parse/Parse.h>
#import "SignUpViewController.h"
#import "HomeScreenViewController.h"
#import "Utility.h"

@interface LoginScreenViewController ()

@end

@implementation LoginScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.LoginButton.backgroundColor = [UIColor colorWithRed:120.0/250.0 green:175.0/250.0 blue:212.0/250.0 alpha:1.0];
        self.facebookLogin.backgroundColor = [UIColor colorWithRed:81.0/250.0 green:117.0/250.0 blue:195.0/250.0 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithRed:230.0/250.0 green:89.0/250.0 blue:89.0/250.0 alpha:1.0];
    self.backButton.backgroundColor = [UIColor whiteColor];
    
    [self.backButton setTitleColor:[UIColor colorWithRed:230.0/250.0 green:89.0/250.0 blue:89.0/250.0 alpha:1.0] forState:UIControlStateNormal];
    self.backButton.layer.cornerRadius = 6; // this value vary as per your desire
    self.backButton.clipsToBounds = YES;
}

// i want this function to execute each time (to bypass login if already logged in)
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupReturnButton];
    // hides keyboard when user hits background
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];

    UITapGestureRecognizer *facebookGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(facebookClicked)];
    self.facebookIconImageView.userInteractionEnabled = YES;
    [self.facebookIconImageView addGestureRecognizer:facebookGestureRecognizer];
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


- (IBAction)loginButton:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0) {
        [[Utility getInstance] showAlertWithMessage:@"Make sure you enter a username and password!" andTitle:@"Oops!"];
    }
    else {
        
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                [[Utility getInstance] showAlertWithMessage:[error.userInfo objectForKey:@"error"] andTitle:@"Sorry!"];
            }
            else {
                HomeScreenViewController* homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
                [self.navigationController pushViewController:homeScreenViewController animated:YES];
                ParsePushUserAssign();
                [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

/// Sets up the done button on keyboard to be blue.
- (void)setupReturnButton {
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    
    [self.usernameField setReturnKeyType:UIReturnKeyNext];
    [self.passwordField setReturnKeyType:UIReturnKeyDone];
}

- (IBAction)facebookLogin:(id)sender {
    [ProgressHUD show:@"Logging in..." Interaction:NO];
    
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
     {
         if (user != nil)
         {
             if (user[PF_USER_FACEBOOKID] == nil) // Not signed in facebook
             {
                 [self requestFacebook:user];
                 //[self performSegueWithIdentifier:@"LoginToMain" sender:self];
             }
             else {
                 [self userLoggedIn:user]; // Signed in facebook
                 //[self performSegueWithIdentifier:@"LoginToMain" sender:self];
             }
         }
         else [ProgressHUD showError:error.userInfo[@"error"]];
     }];
}



- (void)requestFacebook:(PFUser *)user{
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
              if (error != nil) [ProgressHUD showError:error.userInfo[@"error"]];
          }];
           if (image.size.width > 30) image = ResizeImage(image, 30, 30);
           PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
         [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil) [ProgressHUD showError:error.userInfo[@"error"]];
          }];
         user[PF_USER_EMAILCOPY] = userData[@"email"];
         user[PF_USER_USERNAME] = userData[@"name"];
         user[PF_USER_FULLNAME_KEY] = userData[@"name"];
         user[PF_USER_FULLNAME_LOWER] = [userData[@"name"] lowercaseString];
         user[PF_USER_FACEBOOKID] = userData[@"id"];
         user[PF_USER_PICTURE] = filePicture;
         user[PF_USER_THUMBNAIL] = fileThumbnail;
         [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error == nil)
              {
                  [self userLoggedIn:user];
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

- (void)userLoggedIn:(PFUser *)user{
    ParsePushUserAssign();
    [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
//    [self dismissViewControllerAnimated:YES completion:nil];
    HomeScreenViewController* homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
    [self.navigationController pushViewController:homeScreenViewController animated:YES];
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    HomeScreenViewController* homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
    [self.navigationController pushViewController:homeScreenViewController animated:YES];

//    [self performSegueWithIdentifier:@"LoginToMain" sender:self];
}

- (IBAction)signUpButtonClicked:(id)sender {
    SignUpViewController *signUpController = [[SignUpViewController alloc] init];
    [self.navigationController pushViewController:signUpController animated:YES];
    
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end