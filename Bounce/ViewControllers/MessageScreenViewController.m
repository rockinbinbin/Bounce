//
//  MessageScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "MessageScreenViewController.h"
#import "SelectGroupsTableViewController.h"
#import "Utility.h"

@interface MessageScreenViewController ()
@end

@implementation MessageScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *CancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    
    self.navigationItem.leftBarButtonItem = CancelButton;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // background
    self.title = @"New Message";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Register Button
    self.AddGroupsButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.AddGroupsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.AddGroupsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
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
            [[Utility getInstance] showAlertWithMessage:@"Please Enter a radius and time value!" andTitle:@"Oops!"];
        }
        
        else if (![self isNumeric:RadiusString] || ![self isNumeric:TimeString]) {
            [[Utility getInstance] showAlertWithMessage:@"Please Enter a radius and time value!" andTitle:@"Oops!"];
        }
        else {
            AddGroupsTableViewController *controller = (AddGroupsTableViewController *)segue.destinationViewController;
            controller.radius = [RadiusString intValue];
            controller.timeAllocated = [TimeString intValue];
        }
    }
}


- (IBAction)cancelButtonPressed{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)addgroupsButtonClicked:(id)sender {
    NSString *RadiusString = [self.Radius.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *TimeString = [self.TimeAllocated.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // INPUT ERROR MESSAGES
    if ([RadiusString length] == 0 || [TimeString length] == 0) {
        [[Utility getInstance] showAlertWithMessage:@"Please Enter a radius and time value!" andTitle:@"Oops!"];
    }
    
    else if (![self isNumeric:RadiusString] || ![self isNumeric:TimeString]) {
        [[Utility getInstance] showAlertWithMessage:@"Please enter a numeric radius and time value!" andTitle:@"Oops!"];
    }
    else {
        SelectGroupsTableViewController *controller = [[SelectGroupsTableViewController alloc] init];
        controller.radius = [RadiusString intValue];
        controller.timeAllocated = [TimeString intValue];
        [self.navigationController pushViewController:controller animated:YES];
    }

}
@end
