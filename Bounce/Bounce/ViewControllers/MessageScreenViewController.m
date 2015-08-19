//
//  MessageScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "MessageScreenViewController.h"
#import "Utility.h"
#import "AppConstant.h"
#import "RequestManger.h"
#import "HomeScreenViewController.h"
#import "UIView+AutoLayout.h"
#import "homepointListCell.h"
#import "bounce-Swift.h"

@interface MessageScreenViewController ()
@end

@implementation MessageScreenViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = BounceRed;
    self.navigationController.navigationBar.translucent = NO;
    UIView *backgroundView = [UIView new];
    backgroundView.frame = self.view.frame;
    backgroundView.backgroundColor = BounceLightGray;
    [self.tableView setBackgroundView:backgroundView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingNotification:) name:@"SelectedStringNotification" object:nil];
    
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"Quicksand-Regular" size:20];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"WHERE'S HOME?";
    [navLabel sizeToFit];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    
    [self.navigationController setNavigationBarHidden:NO];

    // background
    self.title = @"New Message";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setBarButtonItemLeft:@"common_back_button"];
    UIImage *sendImage = [UIImage imageNamed:@"sendButton"];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithImage:[sendImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonClicked)];
    self.navigationItem.rightBarButtonItem = sendButton;

    self.selectedGroups = [NSMutableArray array];
    self.location_manager = [[CLLocationManager alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
            int radius = 700; // hardcoded radius
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
    NSString* cellId = @"homepointCell";
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

    if ([[self.selectedCells objectAtIndex:indexPath.row] boolValue]) {
        UIImageView *imgView = [UIImageView new];
        imgView.image = [UIImage imageNamed:@"whiteCheck"];
        [cell addSubview:imgView];
        [imgView kgn_pinToRightEdgeOfSuperviewWithOffset:20];
        [imgView kgn_pinToBottomEdgeOfSuperviewWithOffset:20];
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

    
    NSString *usersNearby = [self.nearUsers objectAtIndex:indexPath.row];
    int numUsers = (int)[usersNearby integerValue];

    if (numUsers == 1) {
        cell.usersNearby.text = [NSString stringWithFormat:@"1 user nearby"];
    }
    else if (numUsers != 0) {
        cell.usersNearby.text = [NSString stringWithFormat:@"%@ users nearby",usersNearby];
    }
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
    return self.view.frame.size.height/2.5;
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
            self.homepointImages = [NSMutableArray new];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (PFObject *group in groups) {
                    [self.nearUsers addObject:[NSNumber numberWithInteger:[[ParseManager getInstance] getNearUsersNumberInGroup:group]]];
                    [self.distanceToUserLocation addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                    
                    if ([group valueForKey:PF_GROUP_IMAGE]) {
                        [self.homepointImages addObject:[group valueForKey:PF_GROUP_IMAGE]];
                    }
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
        } else {
            // MOVE TO HOME
            [GlobalVariables setShouldNotOpenRequestView:NO];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}
@end
