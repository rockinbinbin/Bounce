//
//  GroupsListViewController.m
//  ChattingApp
//
//  Created by Shimaa Essam on 3/18/15.
//  Copyright (c) 2015 Shimaa Essam. All rights reserved.
//

#import "RequistsViewController.h"
//#import "MainViewController.h"
#import "ChatView.h"
#import "AppConstant.h"

@interface RequistsViewController ()
{
    NSMutableArray *requests;
}
@end

@implementation RequistsViewController


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
    [self loadRequests];
}

#pragma mark - Load Groups
- (void) loadRequests{
    @try {
        
        // load requests if the user is sender or receiver
        PFQuery *query1 = [PFQuery queryWithClassName:@"Requests"];
        [query1 whereKey:@"Sender" equalTo:[[PFUser currentUser] username]];
        PFQuery *query2 = [PFQuery queryWithClassName:@"Requests"];
        [query2 whereKey:@"receivers" equalTo:[[PFUser currentUser] username]];
        PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:query1, query2, nil]];
        NSArray *resultUsers = [query findObjects];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             requests = [NSMutableArray arrayWithArray:objects];
             if ([requests count] > 0) {
                 [self.groupsTableView reloadData];
             }
         }];
//        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]){
//           [[Utility getInstance] showProgressHudWithMessage:@"Loading ..." withView:self.view];
//           // Call parse manager load all groups
//            [[ParseManager getInstance] setLoadGroupsdelegate:self];
//            [[ParseManager getInstance] loadAllGroups];
//        }else{
//            [[Utility getInstance] showAlertMessage:@"Please Fill All Login Fields"];
//        }

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
        
        requests = [NSMutableArray arrayWithArray:groupsList];
        if ([requests count] > 0) {
            [self.groupsTableView reloadData];
        }
    }
}
#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return requests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.groupsTableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ send request",[[requests objectAtIndex:indexPath.row] valueForKey:@"Sender"]];
//    cell.detailTextLabel.text = 
    
    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self openRequestChat:indexPath.row];
}

#pragma mark - open chat with selected user
- (void) openRequestChat:(NSInteger) groupIndex
{
    PFObject *request = [requests objectAtIndex:groupIndex];
    NSString *requestId = request.objectId;
    
    [[ParseManager getInstance] createMessageItemForUser:[PFUser currentUser] WithGroupId:requestId andDescription:[request objectForKey:@"name"]];
    
    ChatView *chatView = [[ChatView alloc] initWith:requestId];
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
        [self loadRequests];
    }
}

@end
