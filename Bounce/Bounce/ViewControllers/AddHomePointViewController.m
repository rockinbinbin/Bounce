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
#import <Parse/Parse.h>
#import "GroupsListViewController.h"
#import "Utility.h"
#import "Constants.h"
#import "AddGroupUsersViewController.h"
#import "AddLocationScreenViewController.h"
#import "CreateHomepoint.h"
#import "UIView+AutoLayout.h"
#import "homepointListCell.h"

@interface AddHomePointViewController ()

@property (nonatomic) NSInteger cellIndex;

@end

@implementation AddHomePointViewController
{
    NSMutableArray *groups;
    NSMutableArray *groupsDistance;
    NSMutableArray *userJoinedGroups;
    NSInteger selectedIndex;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"Quicksand-Regular" size:20];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"ADD HOMEPOINT";
    [navLabel sizeToFit];
    
    UILabel *nearbyLabel = [UILabel new];
    nearbyLabel.textColor = [UIColor purpleColor];
    nearbyLabel.backgroundColor = BounceLightGray;
    nearbyLabel.textAlignment = NSTextAlignmentCenter;
    nearbyLabel.font = [UIFont fontWithName:@"Quicksand-Regular" size:self.view.frame.size.height/35];
    nearbyLabel.text = @"ARE YOU HOME? \nCHECK OUT HOMEPOINTS NEARBY:";
    nearbyLabel.numberOfLines = 0;
    [self.view addSubview:nearbyLabel];
    [nearbyLabel kgn_pinToTopEdgeOfSuperview];
    [nearbyLabel kgn_sizeToWidth:self.view.frame.size.width];
    [nearbyLabel kgn_sizeToHeight:self.view.frame.size.height/8];
    [nearbyLabel kgn_pinToLeftEdgeOfSuperview];
    
    [self setBarButtonItemLeft:@"common_back_button"];
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"searchIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonClicked)];
    
    searchButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = searchButton;
    
    UIButton *createHP = [UIButton new];
    createHP.tintColor = [UIColor whiteColor];
    createHP.backgroundColor = BounceSeaGreen;
    [createHP setTitle:@"create homepoint" forState:UIControlStateNormal];
    createHP.titleLabel.font = [UIFont fontWithName:@"Quicksand-Regular" size:self.view.frame.size.height/30];
    createHP.titleLabel.textAlignment = NSTextAlignmentCenter;
    [createHP addTarget:self action:@selector(navigateToCreateHomepointView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createHP];
    [createHP kgn_sizeToHeight:self.view.frame.size.height/10];
    [createHP kgn_sizeToWidth:self.view.frame.size.width];
    [createHP kgn_pinToBottomEdgeOfSuperview];
    [createHP kgn_pinToLeftEdgeOfSuperview];
    
    UITableView *tableview = [UITableView new];
    tableview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tableview];
    tableview.delegate = self;
    tableview.dataSource = self;
    self.tableView = tableview;
    [tableview kgn_sizeToWidth:self.view.frame.size.width];
    [tableview kgn_pinToTopEdgeOfSuperviewWithOffset:self.view.frame.size.height/8];
    [tableview kgn_pinToBottomEdgeOfSuperviewWithOffset:self.view.frame.size.height/10];
    [tableview kgn_pinToLeftEdgeOfSuperview];
}

-(void)searchButtonClicked {
    // TODO: push new search view
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[ParseManager getInstance] setUpdateGroupDelegate:self];
    [self loadGroups];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
            self.homepointImages = [NSMutableArray new];
            
            for (PFObject *group in groups) {
                [groupsDistance addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                [userJoinedGroups addObject:[NSNumber numberWithBool:NO]];
                
                if ([group valueForKey:PF_GROUP_IMAGE]) {
                    [self.homepointImages addObject:[group valueForKey:PF_GROUP_IMAGE]];
                }
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

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"homepointListCell";
    homepointListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [homepointListCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([[userJoinedGroups objectAtIndex:indexPath.row] boolValue] == YES) {
        UIImageView *imgView = [UIImageView new];
        imgView.image = [UIImage imageNamed:@"whiteCheck"];
        [cell addSubview:imgView];
        [imgView kgn_pinToRightEdgeOfSuperviewWithOffset:20];
        [imgView kgn_pinToBottomEdgeOfSuperviewWithOffset:20];
    }
    else {
        // add + button here
    }
    
    NSMutableArray *images = [NSMutableArray new];
    for (int i = 0; i < [self.homepointImages count]; i++) {
        PFFile *file = self.homepointImages[i];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                if (indexPath.row == i) {
                    UIImage *image = [UIImage imageWithData:data];
                    [images addObject:image];
                    cell.cellBackground.image = image;
                    cell.cellBackground.contentMode = UIViewContentModeScaleToFill;
                    cell.cellBackground.backgroundColor = [UIColor blackColor]; // this should never show
                }
            }
        }];
    }
    
    cell.homepointName.text = [[groups objectAtIndex:indexPath.row] objectForKey:PF_GROUPS_NAME];
    
    double distance = [[groupsDistance objectAtIndex:indexPath.row] doubleValue];
    if (distance > 2500) {
        distance = distance*0.000189394;
        
        if (distance >= 500) {
            cell.distanceAway.text = @"500+ miles away";
        }
        else {
            cell.distanceAway.text = [NSString stringWithFormat:DISTANCE_MESSAGE_IN_MILES, distance];
        }
    }
    else {
        cell.distanceAway.text = [NSString stringWithFormat:DISTANCE_MESSAGE_IN_FEET, (int)distance];
    }
    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[userJoinedGroups objectAtIndex:indexPath.row]boolValue]) {
        // remove current user from the selected group
        [self deleteUserFromGroup:indexPath.row];
    } else {
        // add current user to the selected group
        [self addUserToGroup:indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.height/2.5;
}

#pragma mark - Add User to selected group

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0) {
        [self requestToJoin];
    }
}

- (void) addUserToGroup:(NSInteger) index
{
    self.cellIndex = index;
    if (!_imageActionSheet) {
        self.imageActionSheet = [[UIActionSheet alloc] initWithTitle:@"A member of this homepoint will have to approve your request."  delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Request to join", nil];
        }
    [self.imageActionSheet showInView:self.view];
   
}

-(void)requestToJoin {
    PFObject *group = [groups objectAtIndex:self.cellIndex];
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [[Utility getInstance] showProgressHudWithMessage:[NSString stringWithFormat:@"Request sent to %@", [group objectForKey:PF_GROUPS_NAME]] withView:self.view];
        selectedIndex = self.cellIndex;
        [[ParseManager getInstance] getTentativeUsersFromGroup:group]; // this adds user to tentative list
    }
}

#pragma mark - Delete user from selected group
- (void) deleteUserFromGroup:(NSInteger) index
{
    @try {
        PFObject *group = [groups objectAtIndex:index];
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:[NSString stringWithFormat:@"removed from %@", [group objectForKey:PF_GROUPS_NAME]] withView:self.view];
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

#pragma mark - update Row
- (void) updateRowAtIndex:(NSInteger) index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

#pragma mark - create Homepoint View
- (void) navigateToCreateHomepointView
{
    @try {
        CreateHomepoint *createhomepoint = [CreateHomepoint new];
        [self.navigationController pushViewController:createhomepoint animated:YES];
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
}
- (void)didFailWithError:(NSError *)error
{
    [[Utility getInstance] hideProgressHud];
}

@end
