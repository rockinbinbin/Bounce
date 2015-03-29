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
#import "RootTabBarController.h"
#import "HomeScreenViewController.h"
#import "Utility.h"

@interface SignupScreenViewController ()

@end

@implementation SignupScreenViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    self.RegisterButton.backgroundColor = [UIColor colorWithRed:120.0/250.0 green:175.0/250.0 blue:212.0/250.0 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithRed:230.0/250.0 green:89.0/250.0 blue:89.0/250.0 alpha:1.0];
    self.backButton.backgroundColor = [UIColor whiteColor];

    [self.backButton setTitleColor:[UIColor colorWithRed:230.0/250.0 green:89.0/250.0 blue:89.0/250.0 alpha:1.0] forState:UIControlStateNormal];
    self.backButton.layer.cornerRadius = 6; // this value vary as per your desire
    self.backButton.clipsToBounds = YES;

    // hides keyboard when user hits background
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    UITapGestureRecognizer *facebookGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(facebookClicked)];
    self.facebookIconImageView.userInteractionEnabled = YES;
    [self.facebookIconImageView addGestureRecognizer:facebookGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
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
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count) {
            NSLog(@"NOT UNIQUE USERNAME"); // write alert to try a different username
            [[Utility getInstance] showAlertWithMessage:@"This user handle seems to be taken. Please choose another!" andTitle:@"Oops!"];
        }
        else {
            if ([username length] == 0 || [password length] == 0){
                [[Utility getInstance] showAlertWithMessage:@"Make sure you enter a username, password!" andTitle:@"Oops!"];
            }
            else if (![username hasPrefix:@"@"]) {
                [[Utility getInstance] showAlertWithMessage:@"User handles must begin with an "@" symbol." andTitle:@"Oops!"];
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

- (void)userLoggedIn:(PFUser *)user   {
    ParsePushUserAssign();
    [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Logged-in user experience -- THIS DOESN'T WORK?
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    HomeScreenViewController* homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
    [self.navigationController pushViewController:homeScreenViewController animated:YES];
    //    [self performSegueWithIdentifier:@"SignUpToMain" sender:self];
}


- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

