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

@end
