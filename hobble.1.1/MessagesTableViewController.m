//
//  MessagesTableViewController.m
//  bounce
//
//  Created by Robin Mehta on 3/9/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "MessagesTableViewController.h"
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "messages.h"
#import "utilities.h"

#import "MessagesTableCell.h"
#import "ChatView.h"

@interface MessagesTableViewController () {
    
    NSMutableArray *messages;
    UIRefreshControl *refreshControl;
}
//@property (strong, nonatomic) IBOutlet UIView *viewEmpty;
@property (strong, nonatomic) IBOutlet UITableView *tableMessages;

@end

@implementation MessagesTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Messages";
    
    [_tableMessages registerNib:[UINib nibWithNibName:@"MessagesTableCell" bundle:nil] forCellReuseIdentifier:@"MessagesTableCell"];
    _tableMessages.tableFooterView = [[UIView alloc] init];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadMessages) forControlEvents:UIControlEventValueChanged];
    [_tableMessages addSubview:refreshControl];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    messages = [[NSMutableArray alloc] init];
    //---------------------------------------------------------------------------------------------------------------------------------------------
   // _viewEmpty.hidden = YES;

}

- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidAppear:animated];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ([PFUser currentUser] != nil)
    {
        [self loadMessages];
    }
    else LoginUser(self);
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
    [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
    [query includeKey:PF_MESSAGES_LASTUSER];
    [query orderByDescending:PF_MESSAGES_UPDATEDACTION];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             [messages removeAllObjects];
             [messages addObjectsFromArray:objects];
             [_tableMessages reloadData];
             [self updateEmptyView];
             [self updateTabCounter];
         }
         else [ProgressHUD showError:@"Network error."];
         [refreshControl endRefreshing];
     }];
}

#pragma mark - Helper methods

- (void)updateEmptyView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    //_viewEmpty.hidden = ([messages count] != 0);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateTabCounter
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    int total = 0;
    for (PFObject *message in messages)
    {
        total += [message[PF_MESSAGES_COUNTER] intValue];
    }
    UITabBarItem *item = self.tabBarController.tabBar.items[1];
    item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
}

#pragma mark - User actions


- (void)actionChat:(NSString *)groupId {
    ChatView *chatView = [[ChatView alloc] initWith:groupId];
    chatView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
}


- (void)actionCleanup {
    [messages removeAllObjects];
    [_tableMessages reloadData];

    UITabBarItem *item = self.tabBarController.tabBar.items[1];
    item.badgeValue = nil;
}

/////// HERE IS THE METHOD FOR THE USER ARRAY DELEGATE :)
- (void)didSelectMultipleUsers:(NSMutableArray *)users {
    NSString *groupId = StartMultipleChat(users);
    [self actionChat:groupId];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [messages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessagesTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagesCell" forIndexPath:indexPath];
    [cell bindData:messages[indexPath.row]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    DeleteMessageItem(messages[indexPath.row]);
    [messages removeObjectAtIndex:indexPath.row];
    [_tableMessages deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self updateEmptyView];
    [self updateTabCounter];
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFObject *message = messages[indexPath.row];
    
    // group ID??
    [self actionChat:message[PF_MESSAGES_GROUPID]];
}

@end
