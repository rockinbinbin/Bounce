//
//  MessageScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "MessageScreenViewController.h"
#import "Utility.h"
#import "ChatListCell.h"
#import "AppConstant.h"
#import "RequestManger.h"
#import "HomeScreenViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "UIView+AutoLayout.h"

@interface MessageScreenViewController ()
@end

@implementation MessageScreenViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingNotification:) name:@"SelectedStringNotification" object:nil];
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"Quicksand-Regular" size:25.0f];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"Where's home?";
    [navLabel sizeToFit];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    
    [self.navigationController setNavigationBarHidden:NO];
    [self disableSlidePanGestureForLeftMenu];
    // background
    self.title = @"New Message";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setBarButtonItemLeft:@"common_back_button"];
    UIImage *sendImage = [UIImage imageNamed:@"sendButton"];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithImage:[sendImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonClicked)];
    self.navigationItem.rightBarButtonItem = sendButton;

    self.selectedGroups = [NSMutableArray array];
    self.location_manager = [[CLLocationManager alloc] init];
    
    UIImage *img = [UIImage imageNamed:@"attic"];
    UIImage *img2 = [UIImage imageNamed:@"door"];
    UIImage *img3 = [UIImage imageNamed:@"cups"];
    UIImage *img4 = [UIImage imageNamed:@"bed"];
    UIImage *img5 = [UIImage imageNamed:@"table"];
    UIImage *img6 = [UIImage imageNamed:@"forestHouse"];
    UIImage *img7 = [UIImage imageNamed:@"newYork"];
    UIImage *img8 = [UIImage imageNamed:@"sanFrancisco"];
    UIImage *img9 = [UIImage imageNamed:@"person"];
    self.images = [[NSArray alloc] initWithObjects:img, img2, img3, img4, img5, img6, img7, img8, img9, nil];
}

- (void)viewWillAppear:(BOOL)animated{
        @try {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Loading..." withView:self.view];
            [[ParseManager getInstance] setGetUserGroupsdelegate:self];
            [[ParseManager getInstance] getUserGroups];
            self.isDataLoaded = NO;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) incomingNotification:(NSNotification *)notification{
    NSString *wordSent = [notification object];
    if (self.isDistanceSent) {
        self.distance = wordSent;
    }
    else{
        self.duration = wordSent;
    }
}

#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName{
    UIImage *menuImage = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(backButtonClicked)];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}

-(void)sendButtonClicked {
    
        for (int i = 0; i < self.selectedCells.count; i++) {
            if ([[self.selectedCells objectAtIndex:i] boolValue]) { // if selected
                [self.selectedGroups addObject:[self.groups objectAtIndex:i]];
            }
        }
        
        if ([self.selectedGroups count]) {
            [self creatMessageRequestToSelectedGroup:self.selectedGroups];
        }
        else {
            UIAlertView *zerolength = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                 message:@"Please select some homepoints!"
                                                                delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [zerolength show];
        }
}

-(void)backButtonClicked{
    //TODO: navigate to the last view controller.
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void) creatMessageRequestToSelectedGroup:(NSArray *) selectedGroups {
    @try {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            int radius = 500; // hardcoded radius
            [[Utility getInstance] showProgressHudWithMessage:COMMON_HUD_SEND_MESSAGE];
            [[RequestManger getInstance] setCreateRequestDelegate:self];
            [[RequestManger getInstance] createrequestToGroups:self.selectedGroups andGender:self.genderMatching withinTime:self.timeAllocated andInRadius:radius];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

- (IBAction)cancelButtonPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"ChatListCell";
    ChatListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
        cell = (ChatListCell *)[nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.roundedView.hidden = YES;
    cell.numOfMessagesLabel.text = @"0";
    
    if ([[self.selectedCells objectAtIndex:indexPath.row] boolValue]) {
        cell.nearbyLabel.hidden = YES;
        cell.numOfFriendsInGroupLabel.hidden = YES;
        cell.iconImageView.hidden = NO;
        cell.iconImageView.image = [UIImage imageNamed:@"common_checkmark_icon"];
    }
    else {
        cell.iconImageView.hidden = YES;
        cell.iconImageView.image = nil;
        cell.iconImageView.hidden = NO;
        if (self.isDataLoaded) {
            cell.groupDistanceLabel.hidden = NO;
            cell.numOfFriendsInGroupLabel.hidden = NO;
            cell.nearbyLabel.hidden = NO;
        }
        else {
            cell.groupDistanceLabel.hidden = YES;
            cell.numOfFriendsInGroupLabel.hidden = YES;
            cell.nearbyLabel.hidden = YES;
        }
    }
    
    if (IS_IPAD) {
        cell.groupNameLabel.font=[cell.groupNameLabel.font fontWithSize:20];
        cell.groupDistanceLabel.font=[cell.groupDistanceLabel.font fontWithSize:12];
    }
    
    for (UIView* view in cell.contentView.subviews) {
        view.backgroundColor = [UIColor clearColor];
    }
    
    ////////////// THE STUPID CODE
    if (indexPath.row == 0) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3)];
        imgView.image = self.images[0];
        UIView *overlay = [[UIView alloc] initWithFrame:imgView.frame];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [imgView addSubview:overlay];
        [cell.contentView addSubview:imgView];
    }
    if (indexPath.row == 1) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3)];
        imgView.image = self.images[1];
        UIView *overlay = [[UIView alloc] initWithFrame:imgView.frame];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [imgView addSubview:overlay];
        [cell.contentView addSubview:imgView];
    }
    if (indexPath.row == 2) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3)];
        imgView.image = self.images[2];
        UIView *overlay = [[UIView alloc] initWithFrame:imgView.frame];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [imgView addSubview:overlay];
        [cell.contentView addSubview:imgView];
    }
    if (indexPath.row == 3) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3)];
        imgView.image = self.images[3];
        UIView *overlay = [[UIView alloc] initWithFrame:imgView.frame];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [imgView addSubview:overlay];
        [cell.contentView addSubview:imgView];
    }
    if (indexPath.row == 4) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3)];
        imgView.image = self.images[4];
        UIView *overlay = [[UIView alloc] initWithFrame:imgView.frame];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [imgView addSubview:overlay];
        [cell.contentView addSubview:imgView];
    }
    if (indexPath.row == 5) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3)];
        imgView.image = self.images[5];
        UIView *overlay = [[UIView alloc] initWithFrame:imgView.frame];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [imgView addSubview:overlay];
        [cell.contentView addSubview:imgView];
    }
    if (indexPath.row == 6) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3)];
        imgView.image = self.images[6];
        UIView *overlay = [[UIView alloc] initWithFrame:imgView.frame];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [imgView addSubview:overlay];
        [cell.contentView addSubview:imgView];
    }
    if (indexPath.row == 7) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3)];
        imgView.image = self.images[7];
        UIView *overlay = [[UIView alloc] initWithFrame:imgView.frame];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [imgView addSubview:overlay];
        [cell.contentView addSubview:imgView];
    }
    
    UILabel *label = [UILabel new];
    label.text = [[self.groups objectAtIndex:indexPath.row] objectForKey:PF_GROUPS_NAME];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Quicksand-Regular" size:30];
    [cell.contentView addSubview:label];
    [label kgn_centerHorizontallyInSuperview];
    [label kgn_centerVerticallyInSuperview];
    
    cell.groupDistanceLabel.text = [NSString stringWithFormat:DISTANCE_MESSAGE, [[self.distanceToUserLocation objectAtIndex:indexPath.row] doubleValue]];
    cell.numOfFriendsInGroupLabel.text = [NSString stringWithFormat:@"%@",[self.nearUsers objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectedCells.count > 0) {
        if ([[self.selectedCells objectAtIndex:indexPath.row] boolValue]) {
            [self.selectedCells replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
        }
        else{
            [self.selectedCells replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
        }
        [self.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.height/3;
}

#pragma mark - Parse LoadGroups delegate
- (void)didLoadUserGroups:(NSArray *)groups WithError:(NSError *)error
{
    @try {
        if (error) {
            [[Utility getInstance] hideProgressHud];
            self.isDataLoaded = YES;
        }else{
            if(!self.groups)
            {
                self.groups = [[NSMutableArray alloc] init];
            }
            self.groups = [NSMutableArray arrayWithArray:groups];
            self.selectedCells = [[NSMutableArray alloc] init];
            for (int i = 0; i < self.groups.count; i++) {
                [self.selectedCells addObject:[NSNumber numberWithBool:NO]];
            }
            // calculate the near users in each group
            // calcultae the distance to the group
            self.nearUsers = [[NSMutableArray alloc] init];
            self.distanceToUserLocation = [[NSMutableArray alloc] init];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (PFObject *group in groups) {
                    [self.nearUsers addObject:[NSNumber numberWithInteger:[[ParseManager getInstance] getNearUsersNumberInGroup:group]]];
                    [self.distanceToUserLocation addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    [[Utility getInstance] hideProgressHud];
                    self.isDataLoaded = YES;
                    [self.tableView reloadData];
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
            self.isDataLoaded = YES;
        }else{
            if(!self.groups)
            {
                self.groups = [[NSMutableArray alloc] init];
            }
            self.groups = [NSMutableArray arrayWithArray:groups];
            // calculate the near users in each group
            // calcultae the distance to the group
            self.nearUsers = [[NSMutableArray alloc] init];
            self.distanceToUserLocation = [[NSMutableArray alloc] init];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (PFObject *group in groups) {
                    [self.nearUsers addObject:[NSNumber numberWithInteger:[[ParseManager getInstance] getNearUsersNumberInGroup:group]]];
                    [self.distanceToUserLocation addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    [[Utility getInstance] hideProgressHud];
                    self.isDataLoaded = YES;
                    [self.tableView reloadData];
                });
            });
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}

#pragma mark - Request Manager Create Request delegate
- (void)didCreateRequestWithError:(NSError *)error
{
    @try {
        [[Utility getInstance] hideProgressHud];
        if (error) {
            //
            [[Utility getInstance] showAlertMessage:FAILURE_SEND_MESSAGE];
        }else{
            // MOVE TO HOME
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}
@end
