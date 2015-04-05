//
//  HomePointGroupsViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "AddGroupUsersViewController.h"
#import "AppConstant.h"
#import "ChatListCell.h"
#import "HomePointSuccessfulCreationViewController.h"
#import <Parse/Parse.h>
#import "AppConstant.h"
#import "ParseManager.h"
#import "Definitions.h"
#import "Utility.h"
#import "UIViewController+AMSlideMenu.h"

@interface AddGroupUsersViewController ()

@end

@implementation AddGroupUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBarButtonItemLeft:@"common_back_button"];
    self.navigationItem.title = @"add to group";
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

- (void) viewWillAppear:(BOOL)animated
{
    // Disable left Slide menu
    [self disableSlidePanGestureForLeftMenu];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    //TODO: make the location implementation, store it or make it nil ! then navigate to the new view controller
    [[Utility getInstance] showProgressHudWithMessage:@"Saving ..." withView:self.view];

    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:ParseGroupName equalTo:self.groupName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // works
            if (objects.count) {
                NSLog(@"NOT UNIQUE GROUP NAME"); // write alert to try a different username
                UIAlertView *notuniqueusername = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                            message:@"This group name seems to be taken. Please choose another!"
                                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [notuniqueusername show];
            }
            else{
                // get selected users
               NSArray *users = [self getCheckedUsers];
                [[ParseManager getInstance] addGroup:self.groupName withArrayOfUser:users withLocation:self.groupLocation andPrivacy:self.groupPrivacy];

                HomePointSuccessfulCreationViewController* homePointSuccessfulCreationViewController = [[HomePointSuccessfulCreationViewController alloc] initWithNibName:@"HomePointSuccessfulCreationViewController" bundle:nil];
                [self.navigationController pushViewController:homePointSuccessfulCreationViewController animated:YES];
            }
            [[Utility getInstance] hideProgressHud];
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

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
    cell.circularView.clipsToBounds = YES;

    cell.topSpaceTitleConstraints.constant = 0;
    
    // filling the cell data
    if ([[self.userChecked objectAtIndex:indexPath.row] boolValue]) {
        cell.iconImageView.image = [UIImage imageNamed:@"common_checkmark_icon"];
    }else{
        cell.iconImageView.image = [UIImage imageNamed:@"common_plus_icon"];
    }
    cell.groupNameLabel.text = [[self.groupUsers objectAtIndex:indexPath.row] objectForKey:PF_USER_USERNAME];
//    cell.groupDistanceLabel.text = @"2.1 miles away";
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSLog(@"%li index is deleted !", (long)indexPath.row);
        //[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // mark this user as checked
    if (indexPath.row != 0) {
        BOOL checked;
        if ([[self.userChecked objectAtIndex:indexPath.row] boolValue]) {
            // mark it to add to group
            checked = NO;
        }else{
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
- (void) updateRowAtIndex:(NSIndexPath*) indexPath
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}
#pragma mark - get Selected users
- (NSArray *) getCheckedUsers
{
    @try {
        NSMutableArray *selectedUsers = [[NSMutableArray alloc] init];
        
        for (int i = 0; i<[self.groupUsers count]; i++) {
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
@end