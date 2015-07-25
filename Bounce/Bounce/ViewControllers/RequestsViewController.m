//
//  GroupsListViewController.m
//  ChattingApp
//
//  Created by Shimaa Essam on 3/18/15.
//  Copyright (c) 2015 Shimaa Essam. All rights reserved.
//

#import "RequestsViewController.h"

#import "CustomChatViewController.h"
#import "AppConstant.h"
#import "Utility.h"
#import "Constants.h"
#import "UIViewController+AMSlideMenu.h"
#import "HomeScreenViewController.h"
#import "ChatListCell.h"

@interface RequestsViewController ()
{
    NSMutableArray *requests;
    NSInteger deletedIndex;
    NSMutableArray *requestValidation;
}
@end

@implementation RequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    [self setBarButtonItemLeft:@"common_back_button"];
    self.navigationItem.title = @"chats";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self disableSlidePanGestureForLeftMenu];
    [self loadRequests];
}
#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName{
    
    UIImage *back = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:back withAction:@selector(backButtonClicked)];
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
    
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    UIViewController *rootVC = [[HomeScreenViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [mainVC.leftMenu openContentNavigationController:nvc];
}
#pragma mark - Load Requests
- (void) loadRequests{
    @try {
        [[ParseManager getInstance] setDelegate:self];
        [[ParseManager getInstance] getUserRequests];
     }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - ParseManger delegate
- (void)didloadAllObjects:(NSArray *)objects
{
    [[Utility getInstance] hideProgressHud];
    requests = [NSMutableArray arrayWithArray:objects];
    requestValidation = [[NSMutableArray alloc] init];
    if ([requests count] > 0) {
        BOOL noMoreValid = NO;
        for (PFObject *request in requests) {
            if (!noMoreValid && [[Utility getInstance] isRequestValid:[request createdAt] andTimeAllocated:[[request objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue]] && ![[request objectForKey:PF_REQUEST_IS_ENDED] boolValue] ) {
                [requestValidation addObject:[NSNumber numberWithBool:YES]];
            }else{
                noMoreValid = YES;
                [requestValidation addObject:[NSNumber numberWithBool:NO]];
            }
        }
        [self.requestsTableView reloadData];
        
    }
}
- (void)didFailWithError:(NSError *)error
{
    [[Utility getInstance] hideProgressHud];
}
#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return requests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"ChatListCell";
    ChatListCell *cell = [self.requestsTableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
        cell = (ChatListCell *)[nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [[cell.contentView viewWithTag:4]removeFromSuperview] ;

    // Hide unneeded elements and show needed ones
    cell.numOfMessagesLabel.hidden = YES;
    cell.numOfFriendsInGroupLabel.hidden = YES;
    cell.nearbyLabel.hidden = YES;
    cell.roundedView.hidden = YES;
    cell.timeLabel.hidden = NO;

    // Decrease the circular view size
    cell.circularViewWidth.constant = 40;
    cell.circularViewHeight.constant = 40;
    cell.circularView.layer.cornerRadius = 20;
    cell.circularView.clipsToBounds = YES;

    if (IS_IPAD) {
        cell.groupNameLabel.font=[cell.groupNameLabel.font fontWithSize:20];
        cell.groupDistanceLabel.font=[cell.groupDistanceLabel.font fontWithSize:12];
    }

    // Setting the elements data
    PFObject *request = [requests objectAtIndex:indexPath.row];
    cell.groupNameLabel.text = [NSString stringWithFormat:@"%@ send request",[[requests objectAtIndex:indexPath.row] valueForKey:@"Sender"]];
    cell.groupDistanceLabel.textColor = [UIColor grayColor];
    cell.groupDistanceLabel.text = [self convertDateToString:[request createdAt]]; // it should be the message content
    cell.timeLabel.text = cell.groupDistanceLabel.text;
    //    cell.iconImageView.image = [UIImage imageNamed:@"common_plus_icon"]; // it should be the user profile

    for ( UIView* view in cell.contentView.subviews )
    {
        view.backgroundColor = [ UIColor clearColor ];
    }
    if ([[Utility getInstance] isRequestValid:[request createdAt] andTimeAllocated:[[request objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue]]) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        self.requestsTableView.backgroundColor = [UIColor whiteColor];
    }else{
        // if request time out ==> added gray background
        cell.contentView.backgroundColor = LIGHT_SELECT_GRAY_COLOR;
        self.requestsTableView.backgroundColor = LIGHT_SELECT_GRAY_COLOR;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // if request time out ==> no action in the cell
    [self openRequestChat:indexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return ![[requestValidation objectAtIndex:indexPath.row] boolValue];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"%li index is deleted !", (long)indexPath.row);
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Delete .." withView:self.view];
            [[ParseManager getInstance] setDeleteDelegate:self];
            [[ParseManager getInstance] deleteRequest:[requests objectAtIndex:indexPath.row]];
        }
    }
}

#pragma mark - open chat with selected user
- (void) openRequestChat:(NSInteger) groupIndex
{
    PFObject *request = [requests objectAtIndex:groupIndex];
    NSString *requestId = request.objectId;
    
//    if ([[Utility getInstance] isRequestValidWithEndDate:[request objectForKey:PF_REQUEST_END_DATE]]) {
    if ([[Utility getInstance] isRequestValid:[request createdAt] andTimeAllocated:[[request objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue]] && ![[request objectForKey:PF_REQUEST_IS_ENDED] boolValue] ) {
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
        //        if ([[NSCalendar currentCalendar] isDateInToday:date]) {
        //            [formatter setDateFormat:@"hh:mm aaa"];
        //
        //        }else{
        //    [formatter setDateFormat:@"EEE,MMM,d"];
        //        }
        [formatter setDateFormat:@"EEE,MMM,d"];
        NSString *stringFromDate = [formatter stringFromDate:date];
        return stringFromDate;
    }
    @catch (NSException *exception) {
        NSLog(@"");
    }
}
#pragma mark - Parse Manager Delete Delegate
- (void)didDeleteObject:(BOOL)succeeded
{
    [[Utility getInstance] hideProgressHud];
    [requests removeObjectAtIndex:deletedIndex];
    
    [self.requestsTableView reloadData];

}
@end
