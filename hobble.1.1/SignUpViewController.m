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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)signupButton:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
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
            if ([username length] == 0 || [password length] == 0) {
                UIAlertView *zerolength = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                    message:@"Make sure you enter a username and password!"
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [zerolength show];
            }
            else if (![username hasPrefix:@"@"]) {
                    UIAlertView *prefix = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                        message:@"User handles must begin with an "@" symbol."
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [prefix show];
                
            }
            else {
                PFUser *newUser = [PFUser user];
                newUser.username = username;
                newUser.password = password;
                
                [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                            message:[error.userInfo objectForKey:@"error"]
                                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                    }
                    else {
                        //                [self.navigationController popToRootViewControllerAnimated:YES];
                        [self performSegueWithIdentifier:@"SignUpToMain" sender:nil];
                    }
                    }];

            }
        }
    }];
}
@end
