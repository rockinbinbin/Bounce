//
//  SettingsViewController.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/10/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)LogoutButton:(id)sender {
    [PFUser logOut];
    PFUser *currentUser = [PFUser currentUser]; // OK for now
    [self performSegueWithIdentifier:@"LogoutToLogin" sender:nil];
}
@end
