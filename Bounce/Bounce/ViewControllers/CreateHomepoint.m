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
#import "UIView+AutoLayout.h"

@implementation CreateHomepoint

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.backgroundColor = BounceRed;
    
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"Quicksand-Regular" size:self.view.frame.size.height/25];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"create homepoint";
    [navLabel sizeToFit];
    
    [self setBarButtonItemLeft:@"common_back_button"];
    
    
    _addPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"addPhotoButton"];
    [_addPhotoButton setImage:img forState:UIControlStateNormal];
    _addPhotoButton.bounds = CGRectMake(0, 0, img.size.width, img.size.height);
    [_addPhotoButton addTarget:self action:@selector(addPhotoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addPhotoButton];
    [_addPhotoButton kgn_pinToTopEdgeOfSuperviewWithOffset:50];
    [_addPhotoButton kgn_centerHorizontallyInSuperview];
    
    _groupNameTextField = [UITextField new];
    _groupNameTextField.backgroundColor = BounceLightGray;
    _groupNameTextField.font = [UIFont fontWithName:@"Quicksand-Regular" size:self.view.frame.size.height/35];
    _groupNameTextField.placeholder = @"group name";
    _groupNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _groupNameTextField.keyboardType = UIKeyboardTypeDefault;
    _groupNameTextField.returnKeyType = UIReturnKeyDone;
    _groupNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _groupNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _groupNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _groupNameTextField.textAlignment = NSTextAlignmentCenter;
    _groupNameTextField.delegate = self;
    [self.view addSubview:_groupNameTextField];
    [_groupNameTextField kgn_pinBottomEdgeToBottomEdgeOfItem:_addPhotoButton withOffset:80];
    [_groupNameTextField kgn_centerHorizontallyInSuperview];
    [_groupNameTextField kgn_sizeToWidth:img.size.width];
    [_groupNameTextField kgn_sizeToHeight:self.view.frame.size.height/15];
    
    
    self.addLocationButton.backgroundColor = LIGHT_BLUE_COLOR;
}

#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName{
    UIImage *menuImage = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(cancelButtonClicked)];
}

-(void)cancelButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}

-(void)doneButtonClicked{
    // will Create group with user location and navigate to add group users screen
    _createButtonClicked = YES;
    [self checkGroupNameValidation];
}

-(void)addPhotoButtonClicked {
             
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

- (void)didFailWithError:(NSError *)error {
    [[Utility getInstance] hideProgressHud];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 20;
}

@end
