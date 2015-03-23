//
//  UsersListViewController.m
//  bounce
//
//  Created by Shimaa Essam on 3/23/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "UsersListViewController.h"

@interface UsersListViewController ()
{
    NSArray *parseUsers;
}
@end

@implementation UsersListViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self) {
        // Custom initialization
        self.title = @"Messages";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    self.navigationItem.hidesBackButton = YES;
//    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutClicked:)];
//    self.navigationItem.rightBarButtonItem = logoutButton;
//    //    UIBarButtonItem *profileButton = [[UIBarButtonItem alloc] initWithTitle:@"Profile" style:UIBarButtonItemStylePlain target:self action:@selector(profileClicked:)];
//    //    self.navigationItem.rightBarButtonItem = profileButton;
//    [self.navigationController setNavigationBarHidden:NO];
//    
//    [self addFriend:@"test"];
}

-(void) sendPushNotificationToUser:(NSString*) username{
    PFQuery *sendToUserQuery = [PFUser query];
    [sendToUserQuery whereKey:@"username" equalTo:username];
    
    // Build the actual push notification target query
    PFQuery *notifucationQuery = [PFInstallation query];
    
    // only return Installations that belong to a User that
    // matches the innerQuery
    [notifucationQuery whereKey:@"user" matchesQuery:sendToUserQuery];
    
    // Send the notification.
    PFPush *push = [[PFPush alloc] init];
    NSDictionary *data = @{@"username" : [[PFUser currentUser] username]};
    [push setQuery:notifucationQuery];
    [push setData:data];
    [push sendPushInBackground];
}

//-(void) addFriend:(NSString*) username{
//    PFRelation *friendsRelationForAdding = [[PFUser currentUser] relationForKey:@"friends"];
//    PFQuery *firstUserQuery = [PFUser query];
//    [firstUserQuery whereKey:@"username" equalTo:username];
//    PFUser *userToAdd = (PFUser *)[firstUserQuery getFirstObject];
//    PFUser *currentUser = [PFUser currentUser];
//    [friendsRelationForAdding addObject:userToAdd];
//    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (error) {
//            NSLog(@"%@ %@", error, [error userInfo]);
//        }
//    }];
//    [PFCloud callFunction:@"editUser" withParameters:@{
//                                                       @"userId": userToAdd.objectId
//                                                       }];
//    [self sendPushNotificationToUser:username];
//}

-(void) removeFriend:(NSString*) username{
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *friendsRelationForRemoving = [[PFUser currentUser]relationForKey:@"friends"];
    PFQuery *firstUserQuery = [PFUser query];
    [firstUserQuery whereKey:@"username" equalTo:username];
    PFUser *userToRemove = (PFUser *)[firstUserQuery getFirstObject];
    [friendsRelationForRemoving removeObject:userToRemove];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"%@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (BOOL)prefersStatusBarHidden {
//    return YES;
//}
- (void)viewWillAppear:(BOOL)animated {
//    [self setFriendsList];
    [self setUsersList];
}

- (void) setUsersList{
//    _usersList = [[NSMutableArray alloc] init];
    dispatch_queue_t firstQueue = dispatch_queue_create("usersList", 0);
    dispatch_async(firstQueue, ^{
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        NSArray* users = [[NSArray alloc] initWithArray:[query findObjects]];
        parseUsers = users;
//        for (int i = 0; i < users.count; i++) {
//            PFObject* currentUserFromCloud = users[i];
//            User* currentUser = [[User alloc] init];
//            currentUser.username = currentUserFromCloud[@"username"];
//            currentUser.email = currentUserFromCloud[@"email"];
//            currentUser.profileImagePath = currentUserFromCloud[@"profileImagePath"];
//            currentUser.emailVerified = [currentUserFromCloud[@"emailVerified"] boolValue];
//            [_usersList addObject:currentUser];
//            
//        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.usersTableView reloadData];
        });
    });
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return parseUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.usersTableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [[parseUsers objectAtIndex:indexPath.row] username];
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 80;
//}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self openChatWithUser:parseUsers[indexPath.row]];
}

#pragma mark - open chat with selected user
- (void)openChatWithUser:(PFUser *)user2
{
    PFUser *user1 = [PFUser currentUser];
    NSString *groupId = [self startPrivateChatBetween:user1 and:user2];
    [self navigateToChatView:groupId];
}

- (NSString*) startPrivateChatBetween:(PFUser *)user1 and:(PFUser *)user2
{
    @try {
        NSString *id1 = user1.objectId;
        NSString *id2 = user2.objectId;
        NSString *groupId = ([id1 compare:id2] < 0) ? [NSString stringWithFormat:@"%@%@", id1, id2] : [NSString stringWithFormat:@"%@%@", id2, id1];
        [[ParseManager getInstance] createMessageItemForUser:user1 WithGroupId:groupId andDescription:user2[PF_USER_FULLNAME]];
        [[ParseManager getInstance] createMessageItemForUser:user2 WithGroupId:groupId andDescription:user1[PF_USER_FULLNAME]];
        return groupId;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

- (void)navigateToChatView:(NSString *)groupId
{
    @try {
        ChatView *chatView = [[ChatView alloc] initWith:groupId];
        chatView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatView animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

@end
