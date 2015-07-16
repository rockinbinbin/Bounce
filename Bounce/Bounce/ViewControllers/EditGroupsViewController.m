//
//  EditGroupsViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "EditGroupsViewController.h"
#import "AppConstant.h"
#import "ChatListCell.h"

#import "AddHomePointViewController.h"
#import <Parse/Parse.h>
#import "ParseManager.h"
#import "Utility.h"
#import "UIViewController+AMSlideMenu.h"

@interface EditGroupsViewController ()

@end

@implementation EditGroupsViewController
{
    NSMutableArray *groupsCreatedBYUser;
    NSMutableArray *groupsDistance;
    NSMutableArray *groupsNearUsers;
    NSInteger selectedIndex;

}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setBarButtonItemLeft:@"common_plus_icon_red"];
    self.navigationItem.title = @"homepoints";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(doneButtonClicked)];
    doneButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = doneButton;
//    self.tableView.allowsMultipleSelectionDuringEditing = NO;
}
- (void) viewWillAppear:(BOOL)animated
{
    [self disableSlidePanGestureForLeftMenu];
    [self getGroupsCreatedByUser];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName{
    UIImage *menuImage = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(addButtonClicked)];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}

-(void)addButtonClicked{
    AddHomePointViewController* addHomePointViewController = [AddHomePointViewController new];
    [self.navigationController pushViewController:addHomePointViewController animated:YES];
}

-(void)doneButtonClicked{
    //TODO: navigate to the last view controller.
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [groupsCreatedBYUser count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"ChatListCell";
    ChatListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
        cell = (ChatListCell *)[nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.roundedView.hidden = YES;
    }
    if (IS_IPAD) {
        cell.groupNameLabel.font=[cell.groupNameLabel.font fontWithSize:20];
        cell.groupDistanceLabel.font=[cell.groupDistanceLabel.font fontWithSize:12];
    }

    // filling the cell data
    cell.groupNameLabel.text = [[groupsCreatedBYUser objectAtIndex:indexPath.row] objectForKey:PF_GROUPS_NAME];
    cell.groupDistanceLabel.text = [NSString stringWithFormat:DISTANCE_MESSAGE_IN_FEET, [[groupsDistance objectAtIndex:indexPath.row] intValue]];
    cell.numOfFriendsInGroupLabel.text = [NSString stringWithFormat:@"%@",[groupsNearUsers objectAtIndex:indexPath.row]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Delete .." withView:self.view];
            selectedIndex = indexPath.row;
            [[ParseManager getInstance] setDeleteDelegate:self];
            [[ParseManager getInstance] removeGroup:[groupsCreatedBYUser objectAtIndex:selectedIndex]];
        }
    }
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark 
- (void) getGroupsCreatedByUser
{
    @try {
        groupsCreatedBYUser = [[NSMutableArray alloc] init];
        groupsDistance = [[NSMutableArray alloc] init];
        groupsNearUsers = [[NSMutableArray alloc] init];
        NSString *userName = [[PFUser currentUser] username];
        for (int i=0 ; i<self.groups.count ; i++) {
            PFObject *group = [self.groups objectAtIndex:i];
            NSLog(@"Group name %@", [group objectForKey: PF_GROUPS_NAME]);
            if ([group objectForKey:PF_GROUP_OWNER]) {
                PFUser *user = [group objectForKey:PF_GROUP_OWNER];
                NSString *ownerName = [user username];
                if ( [ownerName isEqualToString:userName]) {
                    [groupsCreatedBYUser addObject:group];
                    [groupsDistance addObject:[self.distanceToUserLocation objectAtIndex:i]];
                    [groupsNearUsers addObject:[self.nearUsers objectAtIndex:i]];
                }
            }
            
        }
        [self.tableView reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Parse Manger delete delegate
- (void)didDeleteObject:(BOOL)succeeded
{
    @try {
        [[Utility getInstance] hideProgressHud];
        if (succeeded) {
            [groupsCreatedBYUser removeObjectAtIndex:selectedIndex];
            [groupsDistance removeObjectAtIndex:selectedIndex];
            [groupsNearUsers removeObjectAtIndex:selectedIndex];
            [self.tableView reloadData];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
@end
