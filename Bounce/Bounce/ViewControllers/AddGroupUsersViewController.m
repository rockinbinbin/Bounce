//
//  HomePointGroupsViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

// COME BACK TO ANNOTATE

#import "AddGroupUsersViewController.h"
#import "AppConstant.h"
#import "ChatListCell.h"
#import "HomePointSuccessfulCreationViewController.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "ParseManager.h"
//#import "Definitions.h"
#import "Utility.h"
#import "UIViewController+AMSlideMenu.h"

@interface AddGroupUsersViewController ()

@end

@implementation AddGroupUsersViewController {
    BOOL enableSelection;
    NSMutableArray *addedUsers;
    NSMutableArray *deletedUsers;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setBarButtonItemLeft:@"common_back_button"];
    
    if (self.editGroup) { // IF 'EDIT' BOOL -> ADD USERS TO HOMEPOINT (?)
        [self setEditData];
    }
    else {
        self.navigationItem.title = @"Add to Homepoint";
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Done"
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(doneButtonClicked)];
        
        doneButton.tintColor = DEFAULT_COLOR;
        
        self.navigationItem.rightBarButtonItem = doneButton;
        
        // create checked array
        self.userChecked  = [[NSMutableArray alloc] init];
        NSInteger useresCount = [self.groupUsers count];
        [self.userChecked  addObject:[NSNumber numberWithBool:YES]];
        for (int i = 0; i < useresCount-1; i++) {
            [self.userChecked  addObject:[NSNumber numberWithBool:NO]];
        }
    }
}

- (void) setEditData {
    self.navigationItem.title = @"Add to Homepoint";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Save"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(saveButtonClicked)];
    doneButton.tintColor = DEFAULT_COLOR;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    // create checked array
    self.userChecked  = [[NSMutableArray alloc] init];
    NSMutableArray *allUsers = [[NSMutableArray alloc] initWithArray:self.originalGroupUsers];
    
    NSInteger groupUseresCount = [self.originalGroupUsers count];
//    [self.userChecked  addObject:[NSNumber numberWithBool:YES]];
    for (int i = 0; i < groupUseresCount; i++) {
        [self.userChecked  addObject:[NSNumber numberWithBool:YES]];
    }
    
    if (self.remainingUsers) {
        
        [allUsers addObjectsFromArray:self.remainingUsers];
        NSInteger remainingUsersCount = [self.remainingUsers count];
        
        for (int i = 0; i < remainingUsersCount; i++) {
            [self.userChecked  addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    self.groupUsers = [NSArray arrayWithArray:allUsers];

    
    if ([[[PFUser currentUser] username] isEqualToString:[[self.updatedGroup objectForKey:PF_GROUP_OWNER] username]] ) {
        enableSelection = YES;
        self.navigationItem.title = @"Edit Users";
    }
    else {
        self.navigationItem.title = @"Homepoint Users";
    }
}

- (void) viewWillAppear:(BOOL)animated {
    // Disable left Slide menu
    [self disableSlidePanGestureForLeftMenu];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar

// Sets left nav bar button
-(void) setBarButtonItemLeft:(NSString*) imageName {
    UIImage *menuImage = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(cancelButtonClicked)];
}

// Sets nav bar button item with image
-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action {
    
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}

-(void)cancelButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneButtonClicked{
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [[Utility getInstance] showProgressHudWithMessage:@"Saving..." withView:self.view];
        // get selected users
        NSArray *users = [self getCheckedUsers];
        [[ParseManager getInstance] setAddGroupdelegate:self];
        [[ParseManager getInstance] addGroup:self.groupName withArrayOfUser:users withLocation:self.groupLocation andPrivacy:self.groupPrivacy];
    }
}

-(void)saveButtonClicked{
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [[Utility getInstance] showProgressHudWithMessage:@"Saving..." withView:self.view];
         //get selected users
        [self getAddedAndDeletedUsers];
        [[ParseManager getInstance] setUpdateGroupDelegate:self];
//        [[ParseManager getInstance] addListOfUsers:users toGroup:self.updatedGroup];
        [[ParseManager getInstance] addListOfUsers:addedUsers toGroup:self.updatedGroup andRemove:deletedUsers];

    }
}


#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groupUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"ChatListCell";
    ChatListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
        cell = (ChatListCell *)[nib objectAtIndex:0];
    }
    
    cell.numOfMessagesLabel.hidden = YES;
    cell.numOfFriendsInGroupLabel.hidden = YES;
    cell.nearbyLabel.hidden = YES;
    cell.roundedView.hidden = YES;
    cell.groupDistanceLabel.hidden = YES;
    
    cell.circularView.layer.borderWidth = 1.0f;
    cell.circularView.layer.borderColor = DEFAULT_COLOR.CGColor;

    cell.circularViewWidth.constant = 40;
    cell.circularViewHeight.constant = 40;
    cell.circularView.layer.cornerRadius = 20;
    cell.topSpaceTitleConstraints.constant = 0;

    if (IS_IPAD) {
        cell.groupNameLabel.font=[cell.groupNameLabel.font fontWithSize:20];
        cell.groupDistanceLabel.font=[cell.groupDistanceLabel.font fontWithSize:12];
    }

    // filling the cell data: CHECKMARKS
    if ([[self.userChecked objectAtIndex:indexPath.row] boolValue]) {
        cell.iconImageView.image = [UIImage imageNamed:@"common_checkmark_icon"];
    }
    else {
        cell.iconImageView.image = [UIImage imageNamed:@"common_plus_icon"];
    }
    
    cell.groupNameLabel.text = [[self.groupUsers objectAtIndex:indexPath.row] objectForKey:PF_USER_USERNAME];
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // mark this user as checked
    if ((indexPath.row != 0 && !self.editGroup) || (indexPath.row != 0 && self.editGroup && enableSelection)) {
        BOOL checked;
        if ([[self.userChecked objectAtIndex:indexPath.row] boolValue]) {
            // mark it to add to group
            checked = NO;
        }
        else {
            // mark it as not in the group
            checked = YES;
        }
        
        [self.userChecked replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:checked]];
        [self updateRowAtIndex:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - update Row
- (void) updateRowAtIndex:(NSIndexPath*) indexPath {
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}
#pragma mark - get Selected users
- (NSArray *) getCheckedUsers {
    @try {
        NSMutableArray *selectedUsers = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [self.groupUsers count]; i++) {
            if ([[self.userChecked objectAtIndex:i] boolValue]) {
                [selectedUsers addObject:[self.groupUsers objectAtIndex:i]];
            }
        }
        return [NSArray arrayWithArray:selectedUsers];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
- (void) getAddedAndDeletedUsers
{
    @try {
        addedUsers = [[NSMutableArray alloc] init];
        deletedUsers = [[NSMutableArray alloc] init];

        for (int i = 0; i<[self.originalGroupUsers count]; i++) {
            if (![[self.userChecked objectAtIndex:i] boolValue]) {
                [deletedUsers addObject:[self.groupUsers objectAtIndex:i]];
            }
        }
        for (unsigned long i = [self.originalGroupUsers count]; i < [self.groupUsers count]; i++) {
            if ([[self.userChecked objectAtIndex:i] boolValue]) {
                [addedUsers addObject:[self.groupUsers objectAtIndex:i]];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Parse Manger Add Group delegate
- (void)didAddGroupWithError:(NSError *)error {
    @try {
        [[Utility getInstance] hideProgressHud];
        if (!error) {
            HomePointSuccessfulCreationViewController* homePointSuccessfulCreationViewController = [[HomePointSuccessfulCreationViewController alloc] initWithNibName:@"HomePointSuccessfulCreationViewController" bundle:nil];
            [self.navigationController pushViewController:homePointSuccessfulCreationViewController animated:YES];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - Parse Manger Update group delegate
- (void)didUpdateGroupData:(BOOL)succeed {
    @try {
        [[Utility getInstance] hideProgressHud];
        if (succeed) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            //show error message
            [[Utility getInstance] showAlertMessage:@"Updates not saved. Please try again"];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
@end
