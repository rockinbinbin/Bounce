//
//  GroupsListViewController.m
//  ChattingApp
//
//  Created by Shimaa Essam on 3/18/15.
//  Copyright (c) 2015 Shimaa Essam. All rights reserved.
//

#import "RequistsViewController.h"
//#import "MainViewController.h"
//#import "ChatView.h"
#import "CustomChatViewController.h"
#import "AppConstant.h"
#import "Utility.h"
#import "Constants.h"

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
        [query orderByDescending:@"createdAt"];
//        NSArray *resultUsers = [query findObjects];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    PFObject *request = [requests objectAtIndex:indexPath.row];
    if ([[Utility getInstance] isRequestValid:[request createdAt] andTimeAllocated:[[request objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue]]) {
        cell.backgroundColor = [UIColor whiteColor];
    }else{
        // if request time out ==> added gray background
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ send request",[[requests objectAtIndex:indexPath.row] valueForKey:@"Sender"]];
    cell.detailTextLabel.text = [self convertDateToString:[request createdAt]];
    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // if request time out ==> no action in the cell
    [self openRequestChat:indexPath.row];
}

#pragma mark - open chat with selected user
- (void) openRequestChat:(NSInteger) groupIndex
{
    PFObject *request = [requests objectAtIndex:groupIndex];
    NSString *requestId = request.objectId;
    
    if ([[Utility getInstance] isRequestValid:[request createdAt] andTimeAllocated:[[request objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue]]) {
        [[ParseManager getInstance] createMessageItemForUser:[PFUser currentUser] WithGroupId:requestId andDescription:[request objectForKey:@"name"]];
        
        //    ChatView *chatView = [[ChatView alloc] initWith:requestId];
        CustomChatViewController *chatView = [[CustomChatViewController alloc] initWith:requestId];
        
        chatView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatView animated:YES];
    }else{
        // sho alert request time over
        [[Utility getInstance] showAlertMessage:@"Request time over"];
    }
    
    
}

#pragma mark - String from Date
- (NSString*) convertDateToString:(NSDate *) date
{
    @try {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        
    NSString *stringFromDate = [formatter stringFromDate:date];
        return stringFromDate;
    }
    @catch (NSException *exception) {
        NSLog(@"");
    }
}
@end
