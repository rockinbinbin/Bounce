//
//  CreateHomepoint.m
//  bounce
//
//  Created by Robin Mehta on 7/14/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "CreateHomepoint.h"
#import "AddLocationScreenViewController.h"
#import "Utility.h"
#import "AddGroupUsersViewController.h"
#import "AppConstant.h"

@implementation CreateHomepoint

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    self.groupNameTextField.delegate = self;
    
    self.addLocationButton.backgroundColor = LIGHT_BLUE_COLOR;
}

-(void)doneButtonClicked{
    // will Create group with user location and navigate to add group users screen
    _createButtonClicked = YES;
    [self checkGroupNameValidation];
}

#pragma mark - AddLocation screen
- (void) navigateToAddLocationScreen
{
    @try {
        AddLocationScreenViewController *addLocationScreenViewController = [[AddLocationScreenViewController alloc]  initWithNibName:@"AddLocationScreenViewController" bundle:nil];
        //addLocationScreenViewController.groupName = self.groupNameTextField.text;
        [self.navigationController pushViewController:addLocationScreenViewController animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

- (void)groupNameExist:(BOOL)exist
{
    [[Utility getInstance] hideProgressHud];
    if (exist) {
        NSLog(@"NOT UNIQUE GROUP NAME"); // write alert to try a different username
        [[Utility getInstance] showAlertMessage:@"This group name seems to be taken. Please choose another!"];
    }
    else {
//        if (createButtonClicked) {
//            [self getAllUsers];
//        } else {
//            [self navigateToAddLocationScreen];
//        }
    }
//    createButtonClicked = NO;
}

#pragma mark - Get all user
- (void) getAllUsers
{
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [[Utility getInstance] showProgressHudWithMessage:COMMON_HUD_LOADING_MESSAGE];
        [[ParseManager getInstance] setDelegate:self];
        [[ParseManager getInstance] getAllUsers];
    }
}

- (void) checkGroupNameValidation
{
    @try {
        NSString *name = [self.groupNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([name length] == 0) {
            [[Utility getInstance] showAlertMessage:@"Make sure you entered the group name!"];
            _createButtonClicked = NO;
            return;
        }
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@""];
            [[ParseManager getInstance] isGroupNameExist:name];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Parse Manager Delegate
- (void)didloadAllObjects:(NSArray *)objects
{
    [[Utility getInstance] hideProgressHud];
    NSMutableArray *users  = [[NSMutableArray alloc] initWithArray:objects];
    PFUser *currentUser = [PFUser currentUser];
    // Add the current user to the first cell
    [users insertObject:currentUser atIndex:0];
    [self navigateToAddGroupUsersScreenWithUsers:([NSArray arrayWithArray:users])];
    
}

#pragma mark - AddLocation screen
- (void) navigateToAddGroupUsersScreenWithUsers:(NSArray *) users
{
    @try {
        AddGroupUsersViewController *addGroupUsersViewController = [[AddGroupUsersViewController alloc]  initWithNibName:@"AddGroupUsersViewController" bundle:nil];
        addGroupUsersViewController.groupName = self.groupNameTextField.text;
        addGroupUsersViewController.groupLocation = [[PFUser currentUser] objectForKey:PF_USER_LOCATION];
        addGroupUsersViewController.groupUsers = users;
        [self.navigationController pushViewController:addGroupUsersViewController animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

@end
