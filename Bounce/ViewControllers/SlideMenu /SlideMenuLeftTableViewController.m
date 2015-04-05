//
//  LeftMenuTVC.m
//  testProject
//
//  Created by artur on 2/14/14.
//  Copyright (c) 2014 artur. All rights reserved.
//

#import "SlideMenuLeftTableViewController.h"
#import "HomeScreenViewController.h"
#import "RequestsViewController.h"
#import "Constants.h"
#import "AppConstant.h"
#import <ParseManager.h>
#import "LoginScreenViewController.h"
#import "IntroPagesViewController.h"

#define Chats_Section 0
@interface SlideMenuLeftTableViewController ()

@end

@implementation SlideMenuLeftTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self.navigationController navigationBar] setHidden:YES];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor darkGrayColor];
    // Initilizing data souce
    self.tableData = [@[@"Chat"] mutableCopy];
}

-(void) viewWillAppear:(BOOL)animated{
    self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.height / 2;
    self.userProfileImageView.clipsToBounds = YES;
    self.userProfileImageView.layer.borderWidth = 3.0f;
    self.userProfileImageView.layer.borderColor = DEFAULT_COLOR.CGColor;
    [self setUserNameAndLocationAtCell];
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.backgroundColor = [UIColor darkGrayColor];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor darkGrayColor];
    [cell setSelectedBackgroundView:bgColorView];

        cell.textLabel.textColor = [UIColor whiteColor];
     
        int imageYPosition = cell.frame.origin.y + 20;
        // adding chats number
        UIImageView* chatsNumberView = [[UIImageView alloc] initWithFrame:CGRectMake(SIDE_MENU_WIDTH * 4 / 5, imageYPosition - 15, 30, 30)];
        chatsNumberView.backgroundColor = DEFAULT_COLOR;
        chatsNumberView.layer.cornerRadius = chatsNumberView.frame.size.height / 2;
        chatsNumberView.clipsToBounds = YES;
        chatsNumberView.layer.borderWidth = 3.0f;
        chatsNumberView.layer.borderColor = DEFAULT_COLOR.CGColor;
        
        // number of messages for the group
        UILabel* numOfMessagesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 30, 20)];
        numOfMessagesLabel.textAlignment = NSTextAlignmentCenter;
        numOfMessagesLabel.text = @"2";
        [numOfMessagesLabel setTextColor:[UIColor whiteColor]];
        [numOfMessagesLabel setBackgroundColor:[UIColor clearColor]];
        [numOfMessagesLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
        [chatsNumberView addSubview:numOfMessagesLabel];
        [cell addSubview:chatsNumberView];

        // adding chats number
        UIImageView* redCircleView = [[UIImageView alloc] initWithFrame:CGRectMake(20 , imageYPosition - 5, 10, 10)];
        redCircleView.backgroundColor = DEFAULT_COLOR;
        redCircleView.layer.cornerRadius = redCircleView.frame.size.height / 2;
        redCircleView.clipsToBounds = YES;
        redCircleView.layer.borderWidth = 3.0f;
        redCircleView.layer.borderColor = DEFAULT_COLOR.CGColor;
        [cell addSubview:redCircleView];
        
        // adding user name
        UILabel* usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40 , imageYPosition - 20, 100, 40)];
        usernameLabel.font = [UIFont fontWithName:@"FS Albert" size:32];
        usernameLabel.textColor = [UIColor whiteColor];
        usernameLabel.text = @"Chats";
        [cell addSubview:usernameLabel];
        [cell setBackgroundColor:[UIColor darkGrayColor]];

    return cell;
}
#pragma mark - 
- (void) setUserNameAndLocationAtCell{
    @try {
        // adding user name
        PFUser* currentUser = [PFUser currentUser];
        self.usernameLabel.text = [currentUser username];
        self.userCityLabel.text = @"New York City";
        //TODO: Get the actual address of the user by his latitude and longitude
        PFGeoPoint *userGeoPoint = currentUser[@"CurrentLocation"];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nvc;
    UIViewController *rootVC;
    switch (indexPath.row) {
        case Chats_Section:
        {
            rootVC = [[RequestsViewController alloc] initWithNibName:@"RequestsViewController" bundle:nil];
        }
            break;
        
        default:
            break;
    }
    nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    [self openContentNavigationController:nvc];
}

#pragma mark - TableView Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (IBAction)signoutButtonClicked:(id)sender {
    NSLog(@"sign out pressed!");
    [PFUser logOut];
    UINavigationController *nvc;
    UIViewController *rootVC;
    rootVC = [[LoginScreenViewController alloc] init];
    
    
    //
    //    HomeScreenViewController* homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
    //
    //    [self.navigationController popToViewController:homeScreenViewController animated:YES];
    
    IntroPagesViewController* introPagesViewController = [[IntroPagesViewController alloc] initWithNibName:@"IntroPagesViewController" bundle:nil];
    nvc = [[UINavigationController alloc] initWithRootViewController:introPagesViewController];
    [self openContentNavigationController:nvc];
}
@end
