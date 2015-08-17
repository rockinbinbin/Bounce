//
//  GroupsListViewController.m
//  ChattingApp
//
//  Created by Shimaa Essam on 3/18/15.
//  Copyright (c) 2015 Shimaa Essam. All rights reserved.
//

#import "bounce-Swift.h"
#import "AppConstant.h"
#import "Constants.h"
#import "Utility.h"
#import "RequestsViewController.h"
#import "CustomChatViewController.h"
#import "HomeScreenViewController.h"
#import "ChatListCell.h"
#import "chatCell.h"
#import "GroupsListViewController.h"

@interface RequestsViewController () {
    NSMutableArray *requests;
    NSInteger deletedIndex;
    NSMutableArray *requestValidation;
}
@end

#pragma mark Builtin Methods

@implementation RequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.images = [NSMutableArray new];
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.navigationController.navigationBar.barTintColor = BounceRed;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar hideBottomHairline];
    
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:21];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"Leaving Soon Nearby";
    [navLabel sizeToFit];
    
    UITableView *tableView = [UITableView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorColor = BounceRed;
    tableView.backgroundColor = BounceRed;
    [self.view addSubview:tableView];
    self.requestsTableView = tableView;
    [tableView kgn_pinToLeftEdgeOfSuperview];
    [tableView kgn_pinToTopEdgeOfSuperview];
    [tableView kgn_pinToBottomEdgeOfSuperviewWithOffset:0];
    [tableView kgn_sizeToWidth:self.view.frame.size.width];
    
    UIView *bottomView = [UIView new];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    [bottomView kgn_sizeToHeight:130];
    [bottomView kgn_sizeToWidth:self.view.frame.size.width];
    [bottomView kgn_pinToBottomEdgeOfSuperview];
    self.bottomView = bottomView;
    
    UIButton *makeRequest = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    makeRequest.tintColor = [UIColor whiteColor];
    [makeRequest setBackgroundColor:BounceSeaGreen];
    [makeRequest setTitle:@"Create a new leaving group" forState:UIControlStateNormal];
    makeRequest.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
    makeRequest.layer.cornerRadius = 10;
    [makeRequest addTarget:self action:@selector(makeRequestButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:makeRequest];
    [makeRequest kgn_sizeToHeight:53];
    [makeRequest kgn_sizeToWidth:self.view.frame.size.width - 50];
    [makeRequest kgn_centerHorizontallyInSuperview];
    [makeRequest kgn_pinToBottomEdgeOfSuperviewWithOffset:25];
    
    UILabel *leavingGroup = [UILabel new];
    leavingGroup.textColor = [UIColor colorWithWhite:0.0 alpha:0.56];
    leavingGroup.backgroundColor = [UIColor clearColor];
    leavingGroup.textAlignment = NSTextAlignmentCenter;
    leavingGroup.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16];
    leavingGroup.text = @"Didn't find what you're looking for?";
    [bottomView addSubview:leavingGroup];
    [leavingGroup sizeToFit];
    [leavingGroup kgn_centerHorizontallyInSuperview];
    [leavingGroup kgn_positionAboveItem:makeRequest withOffset:10];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.delegate setScrolling:true];

    // For some reason the back button doesn't hide properly.
    // This moves it out of the way.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];

    [self loadRequests];
}

#pragma mark Custom Methods

- (void) makeRequestButtonClicked {
    [GlobalVariables setShouldNotOpenRequestView:true];
    [self.navigationController popViewControllerAnimated:true];
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
    printf("HELLO");
//    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
//    UIViewController *rootVC = [[HomeScreenViewController alloc] init];
//    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
//    [mainVC.leftMenu openContentNavigationController:nvc];
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
            if (!noMoreValid &&
                [[Utility getInstance] isRequestValid:[request createdAt] andTimeAllocated:[[request objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue]] &&
                ![[request objectForKey:PF_REQUEST_IS_ENDED] boolValue]) {
                [requestValidation addObject:[NSNumber numberWithBool:YES]];
            } else {
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
    chatCell *cell = [self.requestsTableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [chatCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //[[cell.contentView viewWithTag:4]removeFromSuperview];
   
    PFObject *request = [requests objectAtIndex:indexPath.row];
    int timeLeft = (int)[[request objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue] - ([[NSDate date] timeIntervalSinceDate:[request createdAt]]/60);
    cell.requestTimeLeft.text = [NSString stringWithFormat:@"Leaving in %d min", timeLeft];

    if ([[Utility getInstance] isRequestValid:[request createdAt] andTimeAllocated:[[request objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue]]) {
        
    } else {
        // if request time out ==> added gray background
        cell.requestTimeLeft.text = @"Bouncin' home!";
    }
    
    NSArray *homepoints = [request valueForKey:PF_REQUEST_HOMEPOINTS];
    
    __block UIImage *image = [UIImage new];

    PFQuery *query = [PFQuery queryWithClassName:PF_GROUPS_CLASS_NAME];
    [query whereKey:PF_GROUPS_NAME equalTo:homepoints[0]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFFile *file = [objects[0] valueForKey:PF_GROUP_IMAGE];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                image = [UIImage imageWithData:data];
                [self.images addObject:image];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.hpImage.image = image;
                    cell.hpImage.contentMode = UIViewContentModeScaleToFill;
                });
            }
        }];
    }];
    
    NSString *hpString = @"To ";
    
    if ([homepoints count] == 1) {
        hpString = [hpString stringByAppendingString:[NSString stringWithFormat:@"%@", homepoints[0]]];
    }
    else {
        for (int i = 0; i < [homepoints count]; i++) {
            hpString = [hpString stringByAppendingString:[NSString stringWithFormat:@"%@", homepoints[i]]];
            
            if (i != ([homepoints count] - 1)) {
                hpString = [hpString stringByAppendingString:@", "];
            }
        }
    }
    cell.requestedGroups.text = hpString;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 113;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
            [[Utility getInstance] showProgressHudWithMessage:@"Deleting..." withView:self.view];
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
    
//  if ([[Utility getInstance] isRequestValidWithEndDate:[request objectForKey:PF_REQUEST_END_DATE]]) {
    if ([[Utility getInstance] isRequestValid:[request createdAt] andTimeAllocated:[[request objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue]] && ![[request objectForKey:PF_REQUEST_IS_ENDED] boolValue] ) {
        [[ParseManager getInstance] createMessageItemForUser:[PFUser currentUser] WithGroupId:requestId andDescription:[request objectForKey:@"name"]];
        
        //    ChatView *chatView = [[ChatView alloc] initWith:requestId];
        CustomChatViewController *chatView = [[CustomChatViewController alloc] initWith:requestId];
        
        chatView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatView animated:YES];
    } else {
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
        [formatter setDateFormat:@"EEE, MMM d"];
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

- (void)navigateToHomepoints {
    GroupsListViewController *groupsListViewController = [GroupsListViewController new];
    [self.navigationController pushViewController:groupsListViewController animated:YES];
}

@end
