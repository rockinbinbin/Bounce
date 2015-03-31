//
//  LeftMenuTVC.m
//  testProject
//
//  Created by artur on 2/14/14.
//  Copyright (c) 2014 artur. All rights reserved.
//

#import "SlideMenuLeftTableViewController.h"
#import "HomeScreenViewController.h"
#import "RequistsViewController.h"
#import "Constants.h"
#import "AppConstant.h"
#import <ParseManager.h>
#import "LoginScreenViewController.h"

#define Profile_Section 0
#define Chats_Section 1
#define Logout_Section 2
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
    self.tableData = [@[@"Home",@"Chat", @"logout"] mutableCopy];
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

    if (indexPath.row == Profile_Section) {
        int imageYPosition = cell.frame.origin.y + 20;
        // adding profile picture
        UIImageView* profileView = [[UIImageView alloc] initWithFrame:CGRectMake(SIDE_MENU_WIDTH / 2 - 50, imageYPosition, 100, 100)];
        profileView.image = [UIImage imageNamed:@"Tutorial-1"];
        profileView.layer.cornerRadius = profileView.frame.size.height / 2;
        profileView.clipsToBounds = YES;
        profileView.layer.borderWidth = 3.0f;
        profileView.layer.borderColor = DEFAULT_COLOR.CGColor;
        [cell addSubview:profileView];
        
        // adding user name
        UILabel* usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(SIDE_MENU_WIDTH / 2 - 50, imageYPosition + 100, 100, 40)];
        usernameLabel.font = [UIFont fontWithName:@"FS Albert" size:32];
        usernameLabel.textColor = [UIColor whiteColor];
        usernameLabel.text = @"Robin Mehta";
        [cell addSubview:usernameLabel];
        
        // adding user location
        UILabel* userLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(SIDE_MENU_WIDTH / 2 - 50, imageYPosition + 120, 100, 40)];
        userLocationLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        userLocationLabel.textColor = [UIColor lightTextColor];
        userLocationLabel.text = @"New York City";
        [cell addSubview:userLocationLabel];
    }
    else if(indexPath.row == Chats_Section){
//        cell.textLabel.text = @"Chats";
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
    }
    else{
        // adding signout button
        int buttonYPosition = cell.frame.size.height * 6;
        NSLog(@"%i",buttonYPosition);
        UIButton* signoutButton = [[UIButton alloc] initWithFrame:CGRectMake(SIDE_MENU_WIDTH / 2 - 70 , buttonYPosition, 140, 30)];
        signoutButton.titleLabel.font = [UIFont fontWithName:@"FS Albert" size:12];
        signoutButton.backgroundColor = [UIColor redColor];
        [signoutButton setTitle:@"Sign out" forState:UIControlStateNormal];
        [signoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [signoutButton addTarget:self   action:@selector(signoutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:signoutButton];
        [cell setUserInteractionEnabled:NO];
    }
    
    return cell;
}

-(void) signoutButtonClicked{
    NSLog(@"sign out pressed!");
    [PFUser logOut];
    UINavigationController *nvc;
    UIViewController *rootVC;
            rootVC = [[LoginScreenViewController alloc] init];

    nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    [self openContentNavigationController:nvc];
//
//    HomeScreenViewController* homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
//
//    [self.navigationController popToViewController:homeScreenViewController animated:YES];
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *nvc;
    UIViewController *rootVC;
    switch (indexPath.row) {
        case Profile_Section:
        {
            rootVC = [[HomeScreenViewController alloc] init];
        }
            break;
        case Chats_Section:
        {
            rootVC = [[RequistsViewController alloc] init];
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
    if ( indexPath.row == Profile_Section) { //profile cell
        return 180;
    }
    else if ( indexPath.row == Chats_Section) { //chats cell
        return 40;
    }
    else { //sign out cell
        return self.view.frame.size.height - 220;
    }
}

@end
