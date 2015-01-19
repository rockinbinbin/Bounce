//
//  NewMessageViewController.m
//  Hobble
//
//  Created by Robin Mehta on 1/17/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "NewMessageViewController.h"

@interface NewMessageViewController ()

@end

@implementation NewMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // background
    self.title = @"New Message";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Register Button
    self.AddGroupsButton.buttonColor = [UIColor redColor];
    self.AddGroupsButton.shadowColor = [UIColor purpleColor];
    self.AddGroupsButton.shadowHeight = 3.0f;
    self.AddGroupsButton.cornerRadius = 6.0f;
    self.AddGroupsButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.AddGroupsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.AddGroupsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    // Username Text Field
    self.Radius.textFieldColor = [UIColor cloudsColor];
    self.Radius.borderColor = [UIColor redColor];
    self.Radius.borderWidth = 3.0f;
    self.Radius.cornerRadius = 6.0f;
    
    // Username Text Field
    self.TimeAllocated.textFieldColor = [UIColor cloudsColor];
    self.TimeAllocated.borderColor = [UIColor redColor];
    self.TimeAllocated.borderWidth = 3.0f;
    self.TimeAllocated.cornerRadius = 6.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) hideKeyboard // when user hits background
{
    [self.TimeAllocated resignFirstResponder];
    [self.Radius resignFirstResponder];
}

// hides keyboard when user clicks return
- (BOOL) textFieldShouldReturn: (UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)isNumeric:(NSString*)inputString{
    BOOL isValid = NO;
    NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
    isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    return isValid;
}

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"NewMessageToAddGroups"]) {
        NSString *RadiusString = [self.Radius.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *TimeString = [self.TimeAllocated.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // INPUT ERROR MESSAGES
        if ([RadiusString length] == 0 || [TimeString length] == 0) {
            UIAlertView *zeroString = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                 message:@"Please Enter a radius and time value!"
                                                                delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [zeroString show];
            
        }
        
        else if (![self isNumeric:RadiusString] || ![self isNumeric:TimeString]) {
            UIAlertView *notNumeric = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                 message:@"Please enter a numeric radius and time value!"
                                                                delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [notNumeric show];
            
        }
        else {
            AddGroupsTableViewController *controller = (AddGroupsTableViewController *)segue.destinationViewController;
            controller.radius = [RadiusString intValue];
            controller.timeAllocated = [TimeString intValue];
        }
    }
}

- (IBAction)unwind:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
