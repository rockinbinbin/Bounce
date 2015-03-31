//
//  CreateGroupViewController.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/19/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import "CreateGroupViewController.h"

@interface CreateGroupViewController ()

- (IBAction)CancelButtonPressed:(id)sender;

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
    
    // background
    self.title = @"Create Group";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Register Button
    self.DoneButton.buttonColor = [UIColor redColor];
    self.DoneButton.shadowColor = [UIColor purpleColor];
    self.DoneButton.shadowHeight = 3.0f;
    self.DoneButton.cornerRadius = 6.0f;
    self.DoneButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.DoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.DoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    // Username Text Field
    self.groupNameTextField.textFieldColor = [UIColor cloudsColor];
    self.groupNameTextField.borderColor = [UIColor redColor];
    self.groupNameTextField.borderWidth = 3.0f;
    self.groupNameTextField.cornerRadius = 6.0f;
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


- (IBAction)CancelButtonPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)Done:(id)sender {
    NSString *name = [self.groupNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([name length] == 0) {
        UIAlertView *zerolength = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                             message:@"Make sure you entered the group name!"
                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [zerolength show];
    }
//    [[ParseManager getInstance] addChatGroup:name];
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

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
                                                                     message:@"Make sure you entered the group name!"
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
        
        // Add current user to the group Relation
        [predefined.groupUsers addObject:[PFUser currentUser]];
        
        // Add the test users to the group
        [[ParseManager getInstance] addListOfUsers:[NSArray arrayWithObjects:@"test",@"shimaa",@"Shimaa Essam",@"test1", nil] toGroup:predefined.Group];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];

    }
}

#pragma mark - Parse Manager Add Group delegate
//- (void)didAddGroupWithError:(NSError *)error
//{
////    [[Utility getInstance] hideProgressHud];
//    if (error) {
//        [[Utility getInstance] showAlertMessage:[[error userInfo] objectForKey:@"error"]];
//    }else{
//        [self loadGroups];
//    }
//}
@end
