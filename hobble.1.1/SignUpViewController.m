//
//  SignUpViewController.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/7/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // hides keyboard when user hits background
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // background
    self.title = @"Create Account";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Next Button
    self.RegisterButton.buttonColor = [UIColor redColor];
    self.RegisterButton.shadowColor = [UIColor purpleColor];
    self.RegisterButton.shadowHeight = 3.0f;
    self.RegisterButton.cornerRadius = 6.0f;
    self.RegisterButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.RegisterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.RegisterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
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
    
    // Gender Field
    self.GenderTextField.textFieldColor = [UIColor cloudsColor];
    self.GenderTextField.borderColor = [UIColor redColor];
    self.GenderTextField.borderWidth = 3.0f;
    self.GenderTextField.cornerRadius = 6.0f;
    
    // Gender Field
    self.PhoneNumberField.textFieldColor = [UIColor cloudsColor];
    self.PhoneNumberField.borderColor = [UIColor redColor];
    self.PhoneNumberField.borderWidth = 3.0f;
    self.PhoneNumberField.cornerRadius = 6.0f;

}

- (void) hideKeyboard // when user hits background
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

// hides keyboard when user clicks return
- (BOOL) textFieldShouldReturn: (UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signupButton:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *gender = [self.GenderTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"Username" equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count) {
            NSLog(@"NOT UNIQUE USERNAME"); // write alert to try a different username
            UIAlertView *notuniqueusername = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                message:@"This user handle seems to be taken. Please choose another!"
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [notuniqueusername show];
        }
        else {
            if ([username length] == 0 || [password length] == 0 || [gender length] == 0) {
                UIAlertView *zerolength = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                    message:@"Make sure you enter a username, password, & gender!"
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [zerolength show];
            }
            else if (![gender isEqualToString:@"Female"] && ![gender isEqualToString: @"female"] && ![gender isEqualToString:@"Male"] && ![gender isEqualToString:@"male"]) {
                UIAlertView *zerolength = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                         message:@"Please enter 'Male' or 'Female' for gender."
                                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [zerolength show];
            }
//            else if (![username hasPrefix:@"@"]) {
//                    UIAlertView *prefix = [[UIAlertView alloc] initWithTitle:@"Oops!"
//                                                                        message:@"User handles must begin with an "@" symbol."
//                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [prefix show];
//                
//            }
            else {
                PFUser *newUser = [PFUser user];
                newUser.username = username;
                newUser.password = password;
                newUser[@"Gender"] = gender;
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                newUser[@"DeviceID"] = currentInstallation.deviceToken;
                
                [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                            message:[error.userInfo objectForKey:@"error"]
                                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                    }
                    else {
                        [self performSegueWithIdentifier:@"SignUpToMain" sender:nil];
                    }
                    }];

            }
        }
    }];
}
- (IBAction)facebookSignin:(id)sender {
    [ProgressHUD show:@"Signing in..." Interaction:NO];
    
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
     {
         if (user != nil)
         {
             if (user[PF_USER_FACEBOOKID] == nil)
             {
                 [self requestFacebook:user];
                 //[self performSegueWithIdentifier:@"SignUpToMain" sender:self];
             }
             else {
                 
                 [self userLoggedIn:user];
                //[self performSegueWithIdentifier:@"SignUpToMain" sender:self];
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
         if (image.size.width > 140) image = ResizeImage(image, 140, 140);
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

@end
