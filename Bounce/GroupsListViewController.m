//
//  GroupsListViewController.m
//  ChattingApp
//
//  Created by Shimaa Essam on 3/18/15.
//  Copyright (c) 2015 Shimaa Essam. All rights reserved.
//

#import "GroupsListViewController.h"
//#import "MainViewController.h"
#import "ChatView.h"

@interface GroupsListViewController ()
{
    NSMutableArray *groups;
}
@end

@implementation GroupsListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
//    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
//    // Add group button
//    UIBarButtonItem *addGroupButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(addGroupClicked)];
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: addGroupButton, logoutButton, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadGroups];
}

#pragma mark - Load Groups
- (void) loadGroups{
    @try {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]){
           [[Utility getInstance] showProgressHudWithMessage:@"Loading ..." withView:self.view];
           // Call parse manager load all groups
            [[ParseManager getInstance] setLoadGroupsdelegate:self];
            [[ParseManager getInstance] loadAllGroups];
        }else{
            [[Utility getInstance] showAlertMessage:@"Please Fill All Login Fields"];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - ParseManger load groups delegate
- (void) didLoadGroups:(NSArray *)groupsList withError:(NSError *)error{
    [[Utility getInstance] hideProgressHud];
    if (error) {
        [[Utility getInstance] showAlertMessage:@"Network Error"];
    }else{
        // set the groups array
        //        if (!groups) {
        //            groups = [[NSMutableArray alloc] init];
        //        }
        
        groups = [NSMutableArray arrayWithArray:groupsList];
        if ([groups count] > 0) {
            [self.groupsTableView reloadData];
        }
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
    UITableViewCell *cell = [self.groupsTableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [[groups objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self openGroupChat:indexPath.row];
}

#pragma mark - open chat with selected user
- (void) openGroupChat:(NSInteger) groupIndex
{
    PFObject *group = [groups objectAtIndex:groupIndex];
    NSString *groupId = group.objectId;
    
    [[ParseManager getInstance] createMessageItemForUser:[PFUser currentUser] WithGroupId:groupId andDescription:[group objectForKey:@"name"]];
    
    ChatView *chatView = [[ChatView alloc] initWith:groupId];
    chatView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
}

//#pragma mark - Bar item button action
//- (void)logout
//{
//    [PFUser logOut];
//    MainViewController *mainViewController = [[MainViewController alloc] init];
//    [self.navigationController pushViewController:mainViewController animated:YES];
//}
- (void) addGroupClicked
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter a name for your group" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([textField.text length] != 0)
        {
            [[ParseManager getInstance] setAddGroupdelegate:self];
            [[ParseManager getInstance] addChatGroup:textField.text];
        }
    }
}

#pragma mark - Parse Manager Add Group delegate
- (void)didAddGroupWithError:(NSError *)error
{
    [[Utility getInstance] hideProgressHud];
    if (error) {
        [[Utility getInstance] showAlertMessage:[[error userInfo] objectForKey:@"error"]];
    }else{
        [self loadGroups];
    }
}

@end
