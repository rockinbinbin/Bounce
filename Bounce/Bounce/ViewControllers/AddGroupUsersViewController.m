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
#import "Utility.h"
#import "UIView+AutoLayout.h"
#import "membersCell.h"

@interface AddGroupUsersViewController ()

@property (nonatomic, strong) NSMutableArray *tentativeUsers;

@end

@implementation AddGroupUsersViewController {
    BOOL enableSelection;
    NSMutableArray *addedUsers;
    NSMutableArray *deletedUsers;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *customButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"common_back_button"]];
    [customButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    
    UITableView *tableView = [UITableView new];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
    [_tableView kgn_pinToTopEdgeOfSuperview];
    [_tableView kgn_pinToLeftEdgeOfSuperview];
    [_tableView kgn_sizeToWidth:self.view.frame.size.width];
    [_tableView kgn_sizeToHeight:self.view.frame.size.height - TAB_BAR_HEIGHT];
    
        UILabel *navLabel = [UILabel new];
        navLabel.textColor = [UIColor whiteColor];
        navLabel.backgroundColor = [UIColor clearColor];
        navLabel.textAlignment = NSTextAlignmentCenter;
        navLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:20];
        self.navigationItem.titleView = navLabel;
        navLabel.text = @"Add roommates";
        [navLabel sizeToFit];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Done"
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(doneButtonClicked)];
        
        doneButton.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = doneButton;
        
        self.userChecked  = [[NSMutableArray alloc] init];
        NSInteger usersCount = [self.candidateUsers count];
        [self.userChecked  addObject:[NSNumber numberWithBool:YES]];
        for (int i = 0; i < usersCount-1; i++) {
            [self.userChecked  addObject:[NSNumber numberWithBool:NO]];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)cancelButtonClicked{
    if (self.editGroup) {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Saving..." withView:self.view];
            //get selected users
            [self getAddedAndDeletedUsers];
            [[ParseManager getInstance] setUpdateGroupDelegate:self];
            //        [[ParseManager getInstance] addListOfUsers:users toGroup:self.updatedGroup];
            [[ParseManager getInstance] addListOfUsers:addedUsers toGroup:self.updatedGroup andRemove:deletedUsers];
            
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneButtonClicked{
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [[Utility getInstance] showProgressHudWithMessage:@"Saving..." withView:self.view];
        // get selected users
        NSArray *users = [self getCheckedUsers];
        [[ParseManager getInstance] setAddGroupdelegate:self];
        [[ParseManager getInstance] addGroup:self.groupName withArrayOfUser:users withLocation:self.groupLocation withImage:self.homepointImage];
    }
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.candidateUsers count];
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
    cell.circularView.layer.borderColor = BounceRed.CGColor;

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
        cell.iconImageView.image = [UIImage imageNamed:@"Plus"];
    }
    
    cell.groupNameLabel.text = [[self.candidateUsers objectAtIndex:indexPath.row] objectForKey:PF_USER_USERNAME];
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
        
        for (int i = 0; i < [self.candidateUsers count]; i++) {
            if ([[self.userChecked objectAtIndex:i] boolValue]) {
                [selectedUsers addObject:[self.candidateUsers objectAtIndex:i]];
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
                [deletedUsers addObject:[self.candidateUsers objectAtIndex:i]];
            }
        }
        for (unsigned long i = [self.originalGroupUsers count]; i < [self.candidateUsers count]; i++) {
            if ([[self.userChecked objectAtIndex:i] boolValue]) {
                [addedUsers addObject:[self.candidateUsers objectAtIndex:i]];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - get Tentative Users
- (void) didLoadTentativeUsers:(NSArray *)tentativeUsers {
     // FIX DIS
}

#pragma mark - Parse Manger Add Group delegate
- (void)didAddGroupWithError:(NSError *)error {
    @try {
        [[Utility getInstance] hideProgressHud];
        if (!error) {
            HomePointSuccessfulCreationViewController* homePointSuccessfulCreationViewController = [HomePointSuccessfulCreationViewController new];
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
        if (!succeed) {
            [[Utility getInstance] showAlertMessage:@"Updates not saved. Please try again"];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
@end
