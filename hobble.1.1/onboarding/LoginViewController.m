//
//  LoginViewController.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/7/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController


// i want this function to execute each time (to bypass login if already logged in)
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setupReturnButton];
    
    // hides keyboard when user hits background
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];

    
\
    
    // background
    self.title = @"Log In";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Log In Button
    self.LoginButton.buttonColor = [UIColor redColor];
    self.LoginButton.shadowColor = [UIColor purpleColor];
    self.LoginButton.shadowHeight = 3.0f;
    self.LoginButton.cornerRadius = 6.0f;
    self.LoginButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.LoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.LoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    // Username Text Field
    self.usernameField.textFieldColor = [UIColor cloudsColor];
    self.usernameField.borderColor = [UIColor redColor];
    self.usernameField.borderWidth = 3.0f;
    self.usernameField.cornerRadius = 6.0f;
    
    // password Text Field
    self.passwordField.textFieldColor = [UIColor cloudsColor];
    self.passwordField.borderColor = [UIColor redColor];
    self.passwordField.borderWidth = 3.0f;
    self.passwordField.cornerRadius = 6.0f;
}

- (void) hideKeyboard // when user hits background
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Make sure you enter a username and password!"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                    message:[error.userInfo objectForKey:@"error"]
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                [self performSegueWithIdentifier:@"LoginToMain" sender:self];
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
             if (user[PF_USER_FACEBOOKID] == nil)
             {
                 [self requestFacebook:user];
                 //[self performSegueWithIdentifier:@"LoginToMain" sender:self];
             }
             else {
                 [self userLoggedIn:user];
                 //[self performSegueWithIdentifier:@"LoginToMain" sender:self];
             }
         }
         else [ProgressHUD showError:error.userInfo[@"error"]];
     }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)requestFacebook:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
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

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSString *link = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         UIImage *image = (UIImage *)responseObject;
         //-----------------------------------------------------------------------------------------------------------------------------------------
         if (image.size.width > 140) {
             
             image = ResizeImage(image, 140, 140);
         }
         //-----------------------------------------------------------------------------------------------------------------------------------------
         PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
         [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil) [ProgressHUD showError:error.userInfo[@"error"]];
          }];
         //-----------------------------------------------------------------------------------------------------------------------------------------
         if (image.size.width > 30) image = ResizeImage(image, 30, 30);
         //-----------------------------------------------------------------------------------------------------------------------------------------
         PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
         [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil) [ProgressHUD showError:error.userInfo[@"error"]];
          }];
         //-----------------------------------------------------------------------------------------------------------------------------------------
         user[PF_USER_EMAILCOPY] = userData[@"email"];
         user[PF_USER_FULLNAME] = userData[@"name"];
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
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [[NSOperationQueue mainQueue] addOperation:operation];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)userLoggedIn:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    ParsePushUserAssign();
    [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    [self performSegueWithIdentifier:@"LoginToMain" sender:self];
}



@end
