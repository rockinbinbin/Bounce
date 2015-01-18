//
//  CreateGroupViewController.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/19/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import "CreateGroupViewController.h"

@interface CreateGroupViewController ()

@end

@implementation CreateGroupViewController

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
    
    self.currentUser = [PFUser currentUser];

    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
}


- (void) hideKeyboard // when user hits background
{
    [self.groupNameTextField resignFirstResponder];
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


- (IBAction)Done:(id)sender {
    NSString *name = [self.groupNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:ParseGroupName equalTo:name];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // works
            if (objects.count) {
                NSLog(@"NOT UNIQUE GROUP NAME"); // write alert to try a different username
                UIAlertView *notuniqueusername = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                        message:@"This group name seems to be taken. Please choose another!"
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [notuniqueusername show];
            }
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    if ([name length] == 0) {
            UIAlertView *zerolength = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                     message:@"Make sure you enter a group name!"
                                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [zerolength show];
        }
            
    else {
        
        // WHAT I DID HERE: created an array of strings as group names stored in the PFUser dash.
        // Also, creates the group object with an array of PFUsers associated.
        
        Definitions *predefined = [[Definitions alloc]init];
        predefined.Group[ParseGroupName] = name;
        
        
        NSMutableArray *Userarray = [[NSMutableArray alloc] init];
        [Userarray addObject:predefined.currentUser];
        
        
        // create an array column object in Group class
        predefined.Group[@"ArrayOfUsers"] = Userarray;
        [predefined.Group saveInBackground];

        PFUser *user = [PFUser currentUser];
        [user addObject:name forKey:@"ArrayOfGroups"];
        [user saveInBackground];

    }
}
@end
