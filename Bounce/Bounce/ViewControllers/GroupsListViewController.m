//
//  GroupsListViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "GroupsListViewController.h"
#import "AddHomePointViewController.h"
#import "AppConstant.h"
#import "Utility.h"
#import "Constants.h"
#import "HomeScreenViewController.h"
#import "AddGroupUsersViewController.h"
#import "bounce-Swift.h"
#import "homepointListCell.h"

@interface GroupsListViewController ()

@property NSArray *images;

@end

@implementation GroupsListViewController
{
    BOOL loadingData;
    NSInteger selectedIndex;
    NSMutableArray *groupUsers;
}

@synthesize nearUsers = nearUsers;
@synthesize distanceToUserLocation = distanceToUserLocation;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.navigationController.navigationBar.barTintColor = BounceRed;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar hideBottomHairline];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    UITableView *tableView = [UITableView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
    [tableView kgn_sizeToWidth:self.view.frame.size.width];
    [tableView kgn_pinToTopEdgeOfSuperview];
    [tableView kgn_pinToBottomEdgeOfSuperview];
    [tableView kgn_pinToLeftEdgeOfSuperview];
    
    UIView *backgroundView = [UIView new];
    backgroundView.frame = self.view.frame;
    backgroundView.backgroundColor = BounceRed;
    [self.tableView setBackgroundView:backgroundView];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self setBarButtonItemRight:@"Plus"];

    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:21];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"HOMEPOINTS";
    [navLabel sizeToFit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.delegate setScrolling:true];
    @try {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Loading..." withView:self.view];
            [[ParseManager getInstance] setGetUserGroupsdelegate:self];
            loadingData = YES;
            [[ParseManager getInstance] getUserGroups];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate setScrolling:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName{

    UIImage *back = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:back withAction:@selector(backButtonClicked)];
}

-(void) setBarButtonItemRight:(NSString*) imageName{
    
    UIImage *add = [UIImage imageNamed:imageName];
    self.navigationItem.rightBarButtonItem = [self initialiseBarButton:add withAction:@selector(addButtonClicked)];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action {
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}

-(void)backButtonClicked {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)addButtonClicked{
    if (!loadingData) {
        AddHomePointViewController* addHomePointViewController = [AddHomePointViewController new];
        [self.navigationController pushViewController:addHomePointViewController animated:YES];
    }
}
#pragma mark - Parse LoadGroups delegate
- (void)didLoadUserGroups:(NSArray *)groups WithError:(NSError *)error
{
    @try {
        if (error) {
            [[Utility getInstance] hideProgressHud];
            loadingData = NO;
        }else{
            if(!self.groups)
            {
                self.groups = [[NSMutableArray alloc] init];
            }
            self.groups = [NSMutableArray arrayWithArray:groups];
            // calculate the near users in each group
            // calcultae the distance to the group
            nearUsers = [[NSMutableArray alloc] init];
            //distanceToUserLocation = [[NSMutableArray alloc] init];
            self.homepointImages = [NSMutableArray new];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (PFObject *group in groups) {
                    [nearUsers addObject:[NSNumber numberWithInteger:[[ParseManager getInstance] getNearUsersNumberInGroup:group]]];
                    //[distanceToUserLocation addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                    
                    if ([group valueForKey:PF_GROUP_IMAGE]) {
                        [self.homepointImages addObject:[group valueForKey:PF_GROUP_IMAGE]];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    [[Utility getInstance] hideProgressHud];
                    [self.tableView reloadData];
                    loadingData = NO;
                });
            });
        }
    }
    @catch (NSException *exception) {
        
    }
}

- (void)didLoadGroups:(NSArray *)groups withError:(NSError *)error
{
    @try {
        if (error) {
            [[Utility getInstance] hideProgressHud];
            loadingData = NO;
        }else{
            if(!self.groups)
            {
                self.groups = [[NSMutableArray alloc] init];
            }
            self.groups = [NSMutableArray arrayWithArray:groups];
            // calculate the near users in each group
            // calcultae the distance to the group
            nearUsers = [[NSMutableArray alloc] init];
            distanceToUserLocation = [[NSMutableArray alloc] init];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (PFObject *group in groups) {
                    [nearUsers addObject:[NSNumber numberWithInteger:[[ParseManager getInstance] getNearUsersNumberInGroup:group]]];
                    [distanceToUserLocation addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    [[Utility getInstance] hideProgressHud];
                    [self.tableView reloadData];
                    loadingData = NO;
                });
            });
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groups count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Deleting..." withView:self.view];
            selectedIndex = indexPath.row;
            [[ParseManager getInstance] setDeleteDelegate:self];
            [[ParseManager getInstance] deleteGroup:[self.groups objectAtIndex:selectedIndex]];
            [self.homepointImages removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"homepointListCell";
    homepointListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [homepointListCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSMutableArray *images = [NSMutableArray new];
    for (int i = 0; i < [self.homepointImages count]; i++) {
        PFFile *file = self.homepointImages[i];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                if (indexPath.row == i) {
                    UIImage *image = [UIImage imageWithData:data];
                    [images addObject:image];
                    cell.cellBackground.image = image;
                    cell.cellBackground.contentMode = UIViewContentModeScaleToFill;
                    cell.cellBackground.backgroundColor = [UIColor blackColor]; // this should never show
                }
            }
        }];
    }
    cell.homepointName.text = [[self.groups objectAtIndex:indexPath.row] objectForKey:PF_GROUPS_NAME];
    
    double distance = [[self.distanceToUserLocation objectAtIndex:indexPath.row] doubleValue];
    if (distance > 2500) {
        distance = distance*0.000189394;
        
        if (distance >= 500) {
            cell.distanceAway.text = @"500+ miles away";
        }
        else {
            cell.distanceAway.text = [NSString stringWithFormat:DISTANCE_MESSAGE_IN_MILES, distance];
        }
    }
    else {
        cell.distanceAway.text = [NSString stringWithFormat:DISTANCE_MESSAGE_IN_FEET, (int)distance];
    }


    NSString *usersNearby = [nearUsers objectAtIndex:indexPath.row];
    int numFriends = (int)[usersNearby integerValue];
    
    if (numFriends == 1) {
        cell.usersNearby.text = [NSString stringWithFormat:@"1 user nearby"];
    }
    else if (numFriends != 0) {
        cell.usersNearby.text = [NSString stringWithFormat:@"%@ users nearby", usersNearby];
    }
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Open Group Users
    selectedIndex = indexPath.row;
    [self editGroupUsers:[self.groups objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.height/2.5;
}

#pragma mark - Parse Manger delete delegate
- (void)didDeleteObject:(BOOL)succeeded
{
    @try {
        [[Utility getInstance] hideProgressHud];
        if (succeeded) {
            [self.groups removeObjectAtIndex:selectedIndex];
            [distanceToUserLocation removeObjectAtIndex:selectedIndex];
            [nearUsers removeObjectAtIndex:selectedIndex];
            [self.tableView reloadData];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Edit User group
- (void) editGroupUsers:(PFObject *) group
{
    // get group user
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [[Utility getInstance] showProgressHudWithMessage:@"Loading Users..." withView:self.view];
        [[ParseManager getInstance] setDelegate:self];
        [[ParseManager getInstance] getGroupUsers:group];
    }
}
#pragma mark - Parse amnger delegate
- (void)didloadAllObjects:(NSArray *)objects
{
    // get remaining users
    groupUsers =  [[NSMutableArray alloc] initWithArray:objects];
    [groupUsers insertObject:[PFUser currentUser] atIndex:0];
    // if the user is group creator
    if ([[[PFUser currentUser] username] isEqualToString:[[[self.groups objectAtIndex:selectedIndex] objectForKey:PF_GROUP_OWNER] username]] ) {

        [[ParseManager getInstance] setLoadNewUsers:self];
        [[ParseManager getInstance] getCandidateUsersForGroup:[self.groups objectAtIndex:selectedIndex]];
    } else {
        [[Utility getInstance] hideProgressHud];
        [self openGroupUsersScreenForEditWithNewUsers:nil];
    }
}
- (void)didloadNewUsers:(NSArray *)users WithError:(NSError *)error
{
        [[Utility getInstance] hideProgressHud];
    if (!error) {
        // navigate to group users screen
        [self openGroupUsersScreenForEditWithNewUsers:users];
    }
}
- (void)didFailWithError:(NSError *)error
{
    [[Utility getInstance] hideProgressHud];
}

#pragma mark - Navigate to GroupUsers screen
- (void) openGroupUsersScreenForEditWithNewUsers:(NSArray *) users
{
    AddGroupUsersViewController * addUser = [AddGroupUsersViewController new];
    //    addUser.groupUsers = objects;
    addUser.editGroup = YES;
    addUser.originalGroupUsers = groupUsers;
    addUser.remainingUsers = users;
    addUser.updatedGroup = [self.groups objectAtIndex:selectedIndex];
    [self.navigationController pushViewController:addUser animated:YES];

}
@end
