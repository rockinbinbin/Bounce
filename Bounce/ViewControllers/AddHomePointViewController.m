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
#import "Definitions.h"
#import <Parse/Parse.h>
#import "ParseManager.h"
#import "GroupsListViewController.h"
#import "Utility.h"
#import "Constants.h"
#import "AddGroupUsersViewController.h"
#import "AddLocationScreenViewController.h"

@interface AddHomePointViewController ()

@end

@implementation AddHomePointViewController
{
    NSMutableArray *groups;
    NSMutableArray *groupsDistance;
    NSMutableArray *userJoinedGroups;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBarButtonItemLeft:@"common_close_icon"];
    self.navigationItem.title = @"add homepoint";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(doneButtonClicked)];
    doneButton.tintColor = DEFAULT_COLOR;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.addLocationButton.backgroundColor = LIGHT_BLUE_COLOR;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
   
}
- (void)viewWillAppear:(BOOL)animated{
    // load all groups that doesn't contain current user
    [self loadGroupsData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - load groups
- (void) loadGroupsData
{
    @try {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Loading..." withView:self.view];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                groups = [[NSMutableArray alloc] initWithArray:[[ParseManager getInstance] getAllGroupsExceptCreatedByUser]];
                groupsDistance = [[NSMutableArray alloc] init];
                userJoinedGroups = [[NSMutableArray alloc] init];

                for (PFObject *group in groups) {
                    [groupsDistance addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                    // if user joined the group mark it joined
                    if ([self isUserJoinedGroup:group]) {
                        [userJoinedGroups addObject:[NSNumber numberWithBool:YES]];
                    }else{
                        [userJoinedGroups addObject:[NSNumber numberWithBool:NO]];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    [[Utility getInstance] hideProgressHud];
                    [self.tableView reloadData];
                });
            });
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
    //TODO: Go to the users screen to add them in the group
   
    
    NSString *name = [self.groupNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([name length] == 0) {
        UIAlertView *zerolength = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                             message:@"Make sure you entered the group name!"
                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [zerolength show];
    }
    else{
        PFQuery *query = [PFQuery queryWithClassName:@"Group"];
        [query whereKey:ParseGroupName equalTo:name];
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
                    // here we add the current user location as default
                    if ([self.groupPrivacySegmentedControl selectedSegmentIndex] == 0) {
                        [[ParseManager getInstance] addGroup:name withLocation:[PFUser currentUser][@"CurrentLocation"] andPrivacy:@"Public"];
                    } else if ([self.groupPrivacySegmentedControl selectedSegmentIndex] == 1) {
                        [[ParseManager getInstance] addGroup:name withLocation:[PFUser currentUser][@"CurrentLocation"] andPrivacy:@"Private"];
                    }
                    GroupsListViewController* groupsListViewController = [[GroupsListViewController alloc] initWithNibName:@"GroupsListViewController" bundle:nil];
                    [self.navigationController pushViewController:groupsListViewController animated:YES];
                    
                }
            }
            else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    
//    HomePointGroupsViewController* homePointGroupsViewController = [[HomePointGroupsViewController alloc] initWithNibName:@"HomePointGroupsViewController" bundle:nil];
//    [self.navigationController pushViewController:homePointGroupsViewController animated:YES];
}

- (IBAction)segmentedControlClicked:(id)sender {
}

- (IBAction)addLocationButtonClicked:(id)sender {

    NSString *name = [self.groupNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:ParseGroupName equalTo:name];
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
                if ([name length] == 0) {
                    UIAlertView *zerolength = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                         message:@"Make sure you entered the group name!"
                                                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [zerolength show];
                }
                else{
                    AddLocationScreenViewController *addLocationScreenViewController = [[AddLocationScreenViewController alloc]  initWithNibName:@"AddLocationScreenViewController" bundle:nil];
                    if ([self.groupPrivacySegmentedControl selectedSegmentIndex] == 0) {
                        addLocationScreenViewController.groupPrivacy = @"Public";
                    } else if ([self.groupPrivacySegmentedControl selectedSegmentIndex] == 1) {
                        addLocationScreenViewController.groupPrivacy = @"Private";
                    }
                    addLocationScreenViewController.groupName = self.groupNameTextField.text;
                    [self.navigationController pushViewController:addLocationScreenViewController animated:YES];
                }
            }
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
    cell.groupNameLabel.font=[cell.groupNameLabel.font fontWithSize:16];
    cell.groupDistanceLabel.font=[cell.groupDistanceLabel.font fontWithSize:10];

    cell.circularViewWidth.constant = 40;
    cell.circularViewHeight.constant = 40;
    cell.circularView.layer.cornerRadius = 20;
    cell.circularView.clipsToBounds = YES;
    cell.circularView.layer.borderWidth = 0;
    cell.circularView.layer.borderColor = [UIColor whiteColor].CGColor;


    if ([[userJoinedGroups objectAtIndex:indexPath.row] boolValue] == YES) {
        cell.iconImageView.image = [UIImage imageNamed:@"common_checkmark_icon"];
    }else{
        cell.iconImageView.image = [UIImage imageNamed:@"common_plus_icon"];
    }
    for ( UIView* view in cell.contentView.subviews )
    {
        view.backgroundColor = [ UIColor clearColor ];
    }

    cell.contentView.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0f];

    // filling the cell data
    
    cell.groupNameLabel.text = [[groups objectAtIndex:indexPath.row] objectForKey:PF_GROUPS_NAME];
    cell.groupDistanceLabel.text = [NSString stringWithFormat:DISTANCE_MESSAGE, [[groupsDistance objectAtIndex:indexPath.row] doubleValue]];

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
    if ([[userJoinedGroups objectAtIndex:indexPath.row]boolValue]) {
        // remove current user from the selected group
        [self deleteUserFromGroup:indexPath.row];
    }else{
        // add current user to the selected group
        [self addUserToGroup:indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - Add User to selected group
- (void) addUserToGroup:(NSInteger) index
{
    @try {
        PFObject *group = [groups objectAtIndex:index];
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:[NSString stringWithFormat:@"Add user to %@", [group objectForKey:PF_GROUPS_NAME]] withView:self.view];
            [[ParseManager getInstance] addCurrentUserToGroup:group];
            [[Utility getInstance] hideProgressHud];
            
            // update group cell
            [userJoinedGroups insertObject:[NSNumber numberWithBool:YES] atIndex:index];
            [self updateRowAtIndex:index];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - 
- (BOOL) isUserJoinedGroup:(PFObject *) group
{
    @try {
        NSArray *userGroups = [[PFUser currentUser] objectForKey:PF_USER_ARRAYOFGROUPS];
        if ([userGroups containsObject:[group objectForKey:PF_GROUPS_NAME]]) {
            return YES;
        }
        
        return NO;
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
            [[ParseManager getInstance] removeUserFromGroup:group];
            [[Utility getInstance] hideProgressHud];
            
            // update group cell
            [userJoinedGroups insertObject:[NSNumber numberWithBool:NO] atIndex:index];
            [self updateRowAtIndex:index];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
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
#pragma mark - 
- (void) hideKeyboard
{
    [self.groupNameTextField resignFirstResponder];
}
@end
