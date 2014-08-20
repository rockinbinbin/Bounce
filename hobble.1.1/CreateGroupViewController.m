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
    // hides keyboard when user hits background
    
    self.groupsRelation = [[PFUser currentUser] objectForKey:ParseGroupRelation];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)Done:(id)sender {
    NSString *name = [self.groupNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:ParseGroupName equalTo:name];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
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
        PFObject *Group = [PFObject objectWithClassName:@"Group"]; // creates an object of a new class called Group
        Group[ParseGroupName] = name;
        [self.groupsRelation addObject:Group]; // creates the relation
            
        [Group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            else {
                [self performSegueWithIdentifier:@"CreateToGroup" sender:nil];
            }
        }];
            

            
//                [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                    if (error) {
//                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
//                                                                            message:[error.userInfo objectForKey:@"error"]
//                                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [alertView show];
//                    }
//                    else {
//                        //                [self.navigationController popToRootViewControllerAnimated:YES];
//                        [self performSegueWithIdentifier:@"SignUpToMain" sender:nil];
//                    }
//                }];
            
            }
}
@end
