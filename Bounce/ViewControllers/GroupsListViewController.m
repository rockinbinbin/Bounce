//
//  GroupsListViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "GroupsListViewController.h"
#import "AddHomePointViewController.h"
#import "ChatListCell.h"
#import "AppConstant.h"
#import "Utility.h"
#import "Constants.h"
#import "UIViewController+AMSlideMenu.h"
#import "HomeScreenViewController.h"
#import "AddGroupUsersViewController.h"

@interface GroupsListViewController ()
@end

@implementation GroupsListViewController
{
    BOOL loadingData;
    NSInteger selectedIndex;
    NSMutableArray *groupUsers;
}
@synthesize nearUsers = nearUsers;
@synthesize distanceToUserLocation = distanceToUserLocation;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    [self setBarButtonItemLeft:@"common_back_button"];
    [self setBarButtonItemRight:@"common_plus_icon_red"];
    self.navigationItem.title = @"homepoints";
}

- (void)viewWillAppear:(BOOL)animated
{
    @try {
        // Disable left Slide menu
        [self disableSlidePanGestureForLeftMenu];
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Loading..." withView:self.view];
            [[ParseManager getInstance] setGetUserGroupsdelegate:self];
            loadingData = YES;
            [[ParseManager getInstance] getUserGroups];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName{

    UIImage *back = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:back withAction:@selector(backButtonClicked)];
}

-(void) setBarButtonItemRight:(NSString*) imageName{
    
    UIImage *add = [UIImage imageNamed:imageName];
    self.navigationItem.rightBarButtonItem = [self initialiseBarButton:add withAction:@selector(addButtonClicked)];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}

-(void)backButtonClicked{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)addButtonClicked{
    if (!loadingData) {
        AddHomePointViewController* addHomePointViewController = [[AddHomePointViewController alloc] initWithNibName:@"AddHomePointViewController" bundle:nil];
        [self.navigationController pushViewController:addHomePointViewController animated:YES];
    }
}
#pragma mark - Parse LoadGroups delegate
- (void)didLoadUserGroups:(NSArray *)groups WithError:(NSError *)error
{
    @try {
        if (error) {
            [[Utility getInstance] hideProgressHud];
            loadingData = NO;
        }else{
            if(!self.groups)
            {
                self.groups = [[NSMutableArray alloc] init];
            }
            self.groups = [NSMutableArray arrayWithArray:groups];
            // calculate the near users in each group
            // calcultae the distance to the group
            nearUsers = [[NSMutableArray alloc] init];
            distanceToUserLocation = [[NSMutableArray alloc] init];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (PFObject *group in groups) {
                    [nearUsers addObject:[NSNumber numberWithInteger:[[ParseManager getInstance] getNearUsersNumberInGroup:group]]];
                    [distanceToUserLocation addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    [[Utility getInstance] hideProgressHud];
                    [self.tableView reloadData];
                    loadingData = NO;
                });
            });
        }
    }
    @catch (NSException *exception) {
        
    }
}
- (void)didLoadGroups:(NSArray *)groups withError:(NSError *)error
{
    @try {
        
        if (error) {
            [[Utility getInstance] hideProgressHud];
            loadingData = NO;
        }else{
            if(!self.groups)
            {
                self.groups = [[NSMutableArray alloc] init];
            }
            self.groups = [NSMutableArray arrayWithArray:groups];
            // calculate the near users in each group
            // calcultae the distance to the group
            nearUsers = [[NSMutableArray alloc] init];
            distanceToUserLocation = [[NSMutableArray alloc] init];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (PFObject *group in groups) {
                    [nearUsers addObject:[NSNumber numberWithInteger:[[ParseManager getInstance] getNearUsersNumberInGroup:group]]];
                    [distanceToUserLocation addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    [[Utility getInstance] hideProgressHud];
                    [self.tableView reloadData];
                    loadingData = NO;
                });
            });
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groups count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Delete .." withView:self.view];
            selectedIndex = indexPath.row;
            [[ParseManager getInstance] setDeleteDelegate:self];
            [[ParseManager getInstance] deleteGroup:[self.groups objectAtIndex:selectedIndex]];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"ChatListCell";
    ChatListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
        cell = (ChatListCell *)[nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
  
    // filling the cell data
    cell.numOfMessagesLabel.text = @"0";
    cell.roundedView.hidden = YES;

    cell.groupNameLabel.text = [[self.groups objectAtIndex:indexPath.row] objectForKey:PF_GROUPS_NAME];
    cell.groupDistanceLabel.text = [NSString stringWithFormat:DISTANCE_MESSAGE, [[distanceToUserLocation objectAtIndex:indexPath.row] doubleValue]];
    cell.numOfFriendsInGroupLabel.text = [NSString stringWithFormat:@"%@",[nearUsers objectAtIndex:indexPath.row]];
    NSLog(@"near users %@", [nearUsers objectAtIndex:indexPath.row]);
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Open Group Users
    selectedIndex = indexPath.row;
    [self editGroupUsers:[self.groups objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - Parse Manger delete delegate
- (void)didDeleteObject:(BOOL)succeeded
{
    @try {
        [[Utility getInstance] hideProgressHud];
        if (succeeded) {
            [self.groups removeObjectAtIndex:selectedIndex];
            [distanceToUserLocation removeObjectAtIndex:selectedIndex];
            [nearUsers removeObjectAtIndex:selectedIndex];
            [self.tableView reloadData];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Edit User group
- (void) editGroupUsers:(PFObject *) group
{
    // get group user
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [[Utility getInstance] showProgressHudWithMessage:@"Load Users..." withView:self.view];
        [[ParseManager getInstance] setDelegate:self];
        [[ParseManager getInstance] getGroupUsers:group];
    }
}
#pragma mark - Parse amnger delegate
- (void)didloadAllObjects:(NSArray *)objects
{
    // get remaining users
    groupUsers =  [[NSMutableArray alloc] initWithArray:objects];
    [groupUsers insertObject:[PFUser currentUser] atIndex:0];
    // if the user is group creator
    if ([[[PFUser currentUser] username] isEqualToString:[[[self.groups objectAtIndex:selectedIndex] objectForKey:PF_GROUP_OWNER] username]] ) {

        [[ParseManager getInstance] setLoadNewUsers:self];
        [[ParseManager getInstance] getCandidateUsersForGroup:[self.groups objectAtIndex:selectedIndex]];
    }else{
        [[Utility getInstance] hideProgressHud];
        [self openGroupUsersScreenForEditWithNewUsers:nil];
    }
}
- (void)didloadNewUsers:(NSArray *)users WithError:(NSError *)error
{
        [[Utility getInstance] hideProgressHud];
    if (!error) {
        // navigate to group user5s screen
        [self openGroupUsersScreenForEditWithNewUsers:users];
    }
}
- (void)didFailWithError:(NSError *)error
{
    [[Utility getInstance] hideProgressHud];

}

#pragma mark - Navigate to GroupUsers screen
- (void) openGroupUsersScreenForEditWithNewUsers:(NSArray *) users
{
    AddGroupUsersViewController * addUser = [[AddGroupUsersViewController alloc] initWithNibName:@"AddGroupUsersViewController" bundle:nil];
    //    addUser.groupUsers = objects;
    addUser.editGroup = YES;
    addUser.originalGroupUsers = groupUsers;
    addUser.remainingUsers = users;
    addUser.updatedGroup = [self.groups objectAtIndex:selectedIndex];
    [self.navigationController pushViewController:addUser animated:YES];

}
@end
