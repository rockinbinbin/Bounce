//
//  AddHomePointViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "AddHomePointViewController.h"
#import "AppConstant.h"
#import "ChatListCell.h"
#import "AddGroupUsersViewController.h"
//#import "Definitions.h"
#import <Parse/Parse.h>
#import "GroupsListViewController.h"
#import "Utility.h"
#import "Constants.h"
#import "AddGroupUsersViewController.h"
#import "AddLocationScreenViewController.h"
#import "UIViewController+AMSlideMenu.h"

@interface AddHomePointViewController ()

@end

@implementation AddHomePointViewController
{
    NSMutableArray *groups;
    NSMutableArray *groupsDistance;
    NSMutableArray *userJoinedGroups;
    NSInteger selectedIndex;
    BOOL createButtonClicked;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    if (IS_IPAD) {
        self.verticalDistanceBetweenTableAndItsBottom.constant = 250;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBarButtonItemLeft:@"common_close_icon"];
    self.groupNameTextField.delegate = self;
    
    self.navigationItem.title = @"add homepoint";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Create"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(doneButtonClicked)];
    doneButton.tintColor = BounceRed;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.addLocationButton.backgroundColor = LIGHT_BLUE_COLOR;
    [self.groupNameTextField addTarget:self
                                action:@selector(textFieldDidChange:)
                      forControlEvents:UIControlEventEditingDidBegin];
    [self.groupNameTextField addTarget:self
                                action:@selector(textFieldDidChangeEnd:)
                      forControlEvents:UIControlEventEditingDidEnd];
}

-(void)textFieldDidChange :(UITextField *)theTextField{
    self.bottomSpaceToGroupName.constant += 200;
}

-(void)textFieldDidChangeEnd :(UITextField *)theTextField{
    self.bottomSpaceToGroupName.constant -= 200;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    createButtonClicked = NO;
    [self disableSlidePanGestureForLeftMenu];     // Disable left Slide menu

    [[ParseManager getInstance] setUpdateGroupDelegate:self];     // Set parse manager update group delegate

    [self loadGroups];     // load all groups that doesn't contain current user
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - load groups
- (void) loadGroups
{
    @try {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Loading..." withView:self.view];
            [[ParseManager getInstance] setLoadGroupsdelegate:self];
            [[ParseManager getInstance] getCandidateGroupsForCurrentUser];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - Parse Loading Groups Manager Delegate
- (void)didLoadGroups:(NSArray *)objects withError:(NSError *)error
{
    @try {
        [[Utility getInstance] hideProgressHud];
        if (!error) {
            groups = [[NSMutableArray alloc] initWithArray:objects];
            groupsDistance = [[NSMutableArray alloc] init];
            userJoinedGroups = [[NSMutableArray alloc] init];
            for (PFObject *group in groups) {
                [groupsDistance addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                [userJoinedGroups addObject:[NSNumber numberWithBool:NO]];
            }
            [[Utility getInstance] hideProgressHud];
            [self.tableView reloadData];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }

}

#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName{
    UIImage *menuImage = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(cancelButtonClicked)];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action{
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
    // will Create group with user location and navigate to add group users screen
    createButtonClicked = YES;
    [self checkGroupNameValidation];
}

- (IBAction)segmentedControlClicked:(id)sender {
}

- (IBAction)addLocationButtonClicked:(id)sender {
    @try {
        [self checkGroupNameValidation];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

- (void) checkGroupNameValidation
{
    @try {
        NSString *name = [self.groupNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([name length] == 0) {
            [[Utility getInstance] showAlertMessage:@"Make sure you entered the group name!"];
            createButtonClicked = NO;
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

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return groups.count;
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
    if (IS_IPAD) {
        cell.groupNameLabel.font=[cell.groupNameLabel.font fontWithSize:20];
        cell.groupDistanceLabel.font=[cell.groupDistanceLabel.font fontWithSize:12];
    }
    
    if ([[userJoinedGroups objectAtIndex:indexPath.row] boolValue] == YES) {
        cell.iconImageView.image = [UIImage imageNamed:@"common_checkmark_icon"];
    }else{
        cell.iconImageView.image = [UIImage imageNamed:@"common_plus_icon"];
    }
    for ( UIView* view in cell.contentView.subviews )
    {
        view.backgroundColor = [ UIColor clearColor ];
    }
    
    cell.contentView.backgroundColor = LIGHT_SELECT_GRAY_COLOR;
    
    // filling the cell data
    
    cell.groupNameLabel.text = [[groups objectAtIndex:indexPath.row] objectForKey:PF_GROUPS_NAME];
    cell.groupDistanceLabel.text = [NSString stringWithFormat:DISTANCE_MESSAGE_IN_FEET, [[groupsDistance objectAtIndex:indexPath.row] doubleValue]];
    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[userJoinedGroups objectAtIndex:indexPath.row]boolValue]) {
        // remove current user from the selected group
        [self deleteUserFromGroup:indexPath.row];
    }else{
        // add current user to the selected group
        [self addUserToGroup:indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - Add User to selected group
- (void) addUserToGroup:(NSInteger) index
{
    @try {
        PFObject *group = [groups objectAtIndex:index];
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:[NSString stringWithFormat:@"Add user to %@", [group objectForKey:PF_GROUPS_NAME]] withView:self.view];
            selectedIndex = index;
            [[ParseManager getInstance] addCurrentUserToGroup:group];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Delete user from selected group
- (void) deleteUserFromGroup:(NSInteger) index
{
    @try {
        PFObject *group = [groups objectAtIndex:index];
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:[NSString stringWithFormat:@"Delete user from %@", [group objectForKey:PF_GROUPS_NAME]] withView:self.view];
            selectedIndex = index;
            [[ParseManager getInstance] removeUserFromGroup:group];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Parse Manager Update Group delegate
- (void)didRemoveUserFromGroup:(BOOL)succeed
{
    [[Utility getInstance] hideProgressHud];
    if (succeed) {
        // update group cell
        [userJoinedGroups insertObject:[NSNumber numberWithBool:NO] atIndex:selectedIndex];
        [self updateRowAtIndex:selectedIndex];
    }
}

- (void)didAddUserToGroup:(BOOL)succeed
{
    [[Utility getInstance] hideProgressHud];
    if (succeed) {
        // update group cell
        [userJoinedGroups insertObject:[NSNumber numberWithBool:YES] atIndex:selectedIndex];
        [self updateRowAtIndex:selectedIndex];
    }
}

- (void)groupNameExist:(BOOL)exist
{
    [[Utility getInstance] hideProgressHud];
    if (exist) {
        NSLog(@"NOT UNIQUE GROUP NAME"); // write alert to try a different username
        [[Utility getInstance] showAlertMessage:@"This group name seems to be taken. Please choose another!"];
    }
    else{
        if (createButtonClicked) {
            // if called from Done Button
            // get all users to load the next view
            [self getAllUsers];
        }else{
            // if called from add location button
            [self navigateToAddLocationScreen];
        }
    }
    createButtonClicked = NO;
}

#pragma mark - update Row
- (void) updateRowAtIndex:(NSInteger) index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}
#pragma mark -
- (void) hideKeyboard
{
    [self.groupNameTextField resignFirstResponder];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}
#pragma mark - AddLocation screen
- (void) navigateToAddLocationScreen
{
    @try {
        AddLocationScreenViewController *addLocationScreenViewController = [[AddLocationScreenViewController alloc]  initWithNibName:@"AddLocationScreenViewController" bundle:nil];
        addLocationScreenViewController.groupPrivacy = [self getSelectedPrivacy];
        addLocationScreenViewController.groupName = self.groupNameTextField.text;
        [self.navigationController pushViewController:addLocationScreenViewController animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Get Privacy
- (NSString *) getSelectedPrivacy
{
    if ([self.groupPrivacySegmentedControl selectedSegmentIndex] == publicGroup) {
        return PUBLIC_GROUP;
    } else {
        return  PRIVATE_GROUP;
    }
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
- (void)didFailWithError:(NSError *)error
{
    [[Utility getInstance] hideProgressHud];
}

#pragma mark - AddLocation screen
- (void) navigateToAddGroupUsersScreenWithUsers:(NSArray *) users
{
    @try {
        AddGroupUsersViewController *addGroupUsersViewController = [[AddGroupUsersViewController alloc]  initWithNibName:@"AddGroupUsersViewController" bundle:nil];
        addGroupUsersViewController.groupPrivacy = [self getSelectedPrivacy];
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
