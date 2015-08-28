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
#import "MembersViewController.h"

@interface GroupsListViewController ()

@property NSArray *images;
@property BOOL firstDone;
@end

@implementation GroupsListViewController
{
    BOOL loadingData;
    NSInteger selectedIndex;
    NSMutableArray *groupUsers;
    NSArray *tentative_users;
    
    // Placeholder content
    UIImageView *placeholderImageView;
    UILabel *placeholderTitle;
    UILabel *placeholderBodyText;
}

@synthesize nearUsers = nearUsers;
@synthesize distanceToUserLocation = distanceToUserLocation;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.firstDone = NO;
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
    navLabel.text = @"Homepoints";
    [navLabel sizeToFit];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_GROUPS_CLASS_NAME];
    [query whereKey:PF_GROUP_Users_RELATION equalTo:[PFUser currentUser]];
    [query includeKey:PF_GROUP_OWNER];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects != nil) {
            if (objects.count == 0) {
                [self.delegate scrollToViewAtIndex:2 animated:false];

                [self showPlaceholder];
            } else {
                [self hidePlaceholder];
            }
        }
    }];
}

#pragma mark Placeholder Methods

/**
 * Renders the placeholder image and text when the user has no homepoints.
 */
- (void)showPlaceholder {
    if (placeholderImageView == nil) {
        placeholderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Homepoints-Placeholder"]];
        [self.tableView.backgroundView addSubview:placeholderImageView];
        [placeholderImageView kgn_pinToTopEdgeOfSuperviewWithOffset:50];
        [placeholderImageView kgn_centerHorizontallyInSuperview];
        [placeholderImageView kgn_sizeToWidthAndHeight:self.view.frame.size.width * 0.64];
    } else {
        placeholderImageView.hidden = false;
    }
    
    if (placeholderTitle == nil) {
        placeholderTitle = [UILabel new];
        placeholderTitle.text = @"Add your first homepoint.";
        placeholderTitle.textColor = [UIColor whiteColor];
        placeholderTitle.textAlignment = NSTextAlignmentCenter;
        placeholderTitle.font = [UIFont fontWithName:@"AvenirNext-Medium" size:23];
        [self.tableView.backgroundView addSubview:placeholderTitle];
        [placeholderTitle kgn_positionBelowItem:placeholderImageView withOffset:50];
        [placeholderTitle kgn_centerHorizontallyInSuperview];
    } else {
        placeholderTitle.hidden = false;
    }
    
    if (placeholderBodyText == nil) {
        placeholderBodyText = [UILabel new];
        placeholderBodyText.text = @"Search for communities nearby – join or create homepoints for your house, apartment, dorm, or neighborhood.";
        placeholderBodyText.textColor = [UIColor whiteColor];
        placeholderBodyText.textAlignment = NSTextAlignmentCenter;
        placeholderBodyText.font = [UIFont fontWithName:@"AvenirNext-Regular" size:19];
        placeholderBodyText.numberOfLines = 0;
        placeholderBodyText.lineBreakMode = NSLineBreakByWordWrapping;
        [self.tableView.backgroundView addSubview:placeholderBodyText];
        [placeholderBodyText kgn_positionBelowItem:placeholderTitle withOffset:30];
        [placeholderBodyText kgn_pinToSideEdgesOfSuperviewWithOffset:46.5];
    } else {
        placeholderBodyText.hidden = false;
    }
}

/**
 * Hides the placeholder image and text when the user has one or more homepoints.
 */
- (void)hidePlaceholder {
    placeholderImageView.hidden = true;
    placeholderTitle.hidden = true;
    placeholderBodyText.hidden = true;
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
    HomepointListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [HomepointListCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    for (int i = 0; i < [self.homepointImages count]; i++) {
        PFFile *file = self.homepointImages[i];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                if (indexPath.row == i) {
                    UIImage *image = [UIImage imageWithData:data];
                    [cell setBackground:image];
                }
            }
        }];
    }
    
    NSString *homepointName = [[[self.groups objectAtIndex:indexPath.row] objectForKey:PF_GROUPS_NAME] uppercaseString];
    [cell setName:homepointName homepointType: HomepointTypeHouse];

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
    // get group users
    self.firstDone = NO;
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [[Utility getInstance] showProgressHudWithMessage:@"Loading Users..." withView:self.view];
        [[ParseManager getInstance] setDelegate:self];
        [[ParseManager getInstance] getGroupUsers:group];
        [[ParseManager getInstance] getTentativeUsersFromGroup:group];
        [[ParseManager getInstance] setGetTentativeUsersDelegate:self];
    }
}
#pragma mark - Parse amnger delegate
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
        members.group = [self.groups objectAtIndex:selectedIndex];
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
        members.group = [self.groups objectAtIndex:selectedIndex];
        [self.navigationController pushViewController:members animated:YES];
    }
}
- (void)didFailWithError:(NSError *)error
{
    [[Utility getInstance] hideProgressHud];
}

#pragma mark - Navigate to GroupUsers screen

@end
