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

    
    if ([PFUser currentUser]) {
        [self performSegueWithIdentifier:@"LoginToMain" sender:nil];
    }
    
    // background
    self.title = @"Log In";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Register Button
    self.RegisterButton.buttonColor = [UIColor redColor];
    self.RegisterButton.shadowColor = [UIColor purpleColor];
    self.RegisterButton.shadowHeight = 3.0f;
    self.RegisterButton.cornerRadius = 6.0f;
    self.RegisterButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.RegisterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.RegisterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
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

@end
