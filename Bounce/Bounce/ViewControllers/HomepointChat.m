//
//  HomepointChat.m
//  bounce
//
//  Created by Robin Mehta on 8/27/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "HomepointChat.h"
#import "Utility.h"
#import "ParseManager.h"
#import "Constants.h"
#import "MembersViewController.h"

@interface HomepointChat ()
@property BOOL firstDone;
@end

@implementation HomepointChat
{
    NSMutableArray *groupUsers;
    NSArray *tentative_users;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"Quicksand-Regular" size:self.view.frame.size.height/23];
    self.navigationItem.titleView = navLabel;
    navLabel.text = [self.homepoint objectForKey:@"groupName"];
    [navLabel sizeToFit];
    
    self.navigationController.navigationBar.barTintColor = BounceRed;
    self.navigationController.navigationBar.translucent = NO;
    UIButton *customButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"common_back_button"]];
    UIButton *usersButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"addWhiteUser"]];
    [usersButton addTarget:self action:@selector(userButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [customButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:usersButton];
}

- (void)loadMessages{
    // is Request still valid
    // retreive requet
    // validate request end
    // if request still valid
    //    self.currentRequest = [[ParseManager getInstance] retrieveRequest:self.currentRequest];
    
    [super loadMessages];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        self.currentRequest = [[ParseManager getInstance] retrieveRequestUpdate:self.groupId];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            BOOL requestEnded = [[self.currentRequest objectForKey:PF_REQUEST_IS_ENDED] boolValue];
//            if (self.currentRequest&& !requestEnded && [[Utility getInstance] isRequestValid:self.currentRequest.createdAt andTimeAllocated:[[self.currentRequest objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue]]) {
//                if (![self isUserStillReceiverForTheRequest]) {
//                    [self clearMessagesAndStopUpdate];
//                    [self showAlertViewWithMessage:@"Oops! Looks like you're no longer within the request radius."];
//                }
//            }
//            else {
//                // delete all messages
//                [self clearMessagesAndStopUpdate];
//                [self showAlertViewWithMessage:@"Request time over"];
//            }
//            
//        });
//    });
}

- (void)didFailWithError:(NSError *)error {
    [[Utility getInstance] hideProgressHud];
}

#pragma mark - Clear Messages
- (void) clearMessagesAndStopUpdate
{
    @try {
        [self.messages removeAllObjects];
        [self.collectionView reloadData];
        [self.timer invalidate];
    }
    @catch (NSException *exception) {
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - back Button Action
-(void)backButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)userButtonClicked {
    // get group users
    self.firstDone = NO;
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [[Utility getInstance] showProgressHudWithMessage:@"Loading Users..." withView:self.view];
        [[ParseManager getInstance] setDelegate:self];
        [[ParseManager getInstance] getGroupUsers:self.homepoint];
        [[ParseManager getInstance] getTentativeUsersFromGroup:self.homepoint];
        [[ParseManager getInstance] setGetTentativeUsersDelegate:self];
    }
}

#pragma mark - Parse manager delegate
- (void)didloadAllObjects:(NSArray *)objects
{
    groupUsers =  [[NSMutableArray alloc] initWithArray:objects];
    [groupUsers insertObject:[PFUser currentUser] atIndex:0];
    if (!self.firstDone) {
        self.firstDone = YES;
    }
    else {
        [[Utility getInstance] hideProgressHud];
        MembersViewController *members = [MembersViewController new];
        members.tentativeUsers = tentative_users;
        members.actualUsers = groupUsers;
        members.group = self.homepoint;
        [self.navigationController pushViewController:members animated:YES];
    }
}
- (void)didLoadTentativeUsers:(NSArray *)tentativeUsers
{
    tentative_users = tentativeUsers;
    if (!self.firstDone) {
        self.firstDone = YES;
    }
    else {
        [[Utility getInstance] hideProgressHud];
        MembersViewController *members = [MembersViewController new];
        members.tentativeUsers = tentative_users;
        members.actualUsers = groupUsers;
        members.group = self.homepoint;
        [self.navigationController pushViewController:members animated:YES];
    }
}

@end
