//
//  HomeScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "RequestsViewController.h"
#import "CustomChatViewController.h"
#import "bounce-Swift.h"
#import "HomepointDropdownCell.h"
#import <QuartzCore/QuartzCore.h>

@interface HomeScreenViewController ()

@property (strong, nonatomic) CLLocationManager *location_manager;
@property (weak, nonatomic) MKMapView *map;
@property (weak, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UIButton *getHomeButton;
@property (weak, nonatomic) UIButton *leftMenuButton;
@property (weak, nonatomic) NSString *genderMatching;
@property (nonatomic) float timeAllocated; // in minutes
@property (nonatomic, strong) UIActionSheet *imageActionSheet;
@property (nonatomic, strong) UIDatePicker *datePicker;


@property NSMutableArray *groups;
@property NSMutableArray *nearUsers;
@property NSMutableArray *selectedCells;
@property NSMutableArray *homepointDistances;
@property NSArray *images;
@property (nonatomic, strong) PFObject *Request;
@property (nonatomic, strong) NSMutableArray *selectedGroups;
@property (nonatomic) BOOL isDataLoaded;

@property (nonatomic, weak) UIButton *time;
@property (nonatomic, weak) UIButton *genders;

@property NSMutableArray *homepointImages;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIView *shadowView;

@property (nonatomic, weak) UIButton *selectHP;


@end

@implementation HomeScreenViewController

# pragma mark Builtin Functions

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BounceRed;
    
    [self.navigationController.navigationBar hideBottomHairline];
    
    [[ParseManager getInstance] setGetUserGroupsdelegate:self];
    [[ParseManager getInstance] getUserGroups];
    self.isDataLoaded = NO;

    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navigationController.navigationBar.barTintColor = BounceRed;
    self.navigationController.navigationBar.translucent = NO;
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"Quicksand-Regular" size:32];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"bounce";
    [navLabel sizeToFit];
    
    [[RequestManger getInstance] loadActiveRequest];
    
    self.genderMatching = ALL_GENDER;
    
    MKMapView *tempMap = [MKMapView new];
    tempMap.scrollEnabled = NO;
    [self.view addSubview:tempMap];
    [tempMap kgn_pinToLeftEdgeOfSuperview];
    [tempMap kgn_pinToRightEdgeOfSuperview];
    [tempMap kgn_sizeToWidth:self.view.frame.size.width];
    [tempMap kgn_sizeToHeight:self.view.frame.size.height/3];
    self.map = tempMap;
    
    UIImageView *whiteLogo = [UIImageView new];
    [whiteLogo setImage:[UIImage imageNamed:@"whiteLogo"]];
    [self.view addSubview:whiteLogo];
    [whiteLogo kgn_pinToLeftEdgeOfSuperviewWithOffset:15];
    [whiteLogo kgn_positionBelowItem:tempMap withOffset:30];
    
    UILabel *goingTo = [UILabel new];
    goingTo.textColor = [UIColor whiteColor];
    goingTo.backgroundColor = [UIColor clearColor];
    goingTo.textAlignment = NSTextAlignmentCenter;
    goingTo.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
    goingTo.text = @"I'm going to";
    [self.view addSubview:goingTo];
    [goingTo sizeToFit];
    [goingTo kgn_positionToTheRightOfItem:whiteLogo withOffset:15];
    [goingTo kgn_positionBelowItem:tempMap withOffset:34];
    
    UIButton *selectHP = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [selectHP setBackgroundColor:[UIColor clearColor]];
    selectHP.tintColor = [UIColor whiteColor];
    [selectHP setTitle:@"select a homepoint" forState:UIControlStateNormal];
    selectHP.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:18];
    [selectHP addTarget:self action:@selector(showDropDown) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectHP];
    self.selectHP = selectHP;
    [selectHP kgn_sizeToHeight:25];
    [selectHP kgn_positionToTheRightOfItem:goingTo withOffset:10];
    [selectHP kgn_positionBelowItem:tempMap withOffset:34];
    
    UIImageView *clockIcon = [UIImageView new];
    [clockIcon setImage:[UIImage imageNamed:@"whiteClock"]];
    [self.view addSubview:clockIcon];
    [clockIcon kgn_pinToLeftEdgeOfSuperviewWithOffset:15];
    [clockIcon kgn_positionBelowItem:whiteLogo withOffset:30];
    
    UILabel *atAround = [UILabel new];
    atAround.textColor = [UIColor whiteColor];
    atAround.backgroundColor = [UIColor clearColor];
    atAround.textAlignment = NSTextAlignmentCenter;
    atAround.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
    atAround.text = @"in approx";
    [self.view addSubview:atAround];
    [atAround sizeToFit];
    [atAround kgn_positionToTheRightOfItem:clockIcon withOffset:15];
    [atAround kgn_positionBelowItem:whiteLogo withOffset:34];
    
    UIButton *time = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [time setBackgroundColor:[UIColor clearColor]];
    time.tintColor = [UIColor whiteColor];
    [time setTitle:@"2 hours & 0 min" forState:UIControlStateNormal];
    time.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:18];
    [time addTarget:self action:@selector(pickTime) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:time];
    self.time = time;
    [time kgn_sizeToHeight:25];
    [time kgn_positionToTheRightOfItem:atAround withOffset:10];
    [time kgn_positionBelowItem:whiteLogo withOffset:34];
    
    UIImageView *genderIcon = [UIImageView new];
    [genderIcon setImage:[UIImage imageNamed:@"genderIcon"]];
    [self.view addSubview:genderIcon];
    [genderIcon kgn_pinToLeftEdgeOfSuperviewWithOffset:15];
    [genderIcon kgn_positionBelowItem:clockIcon withOffset:30];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    [self.view addSubview:lineView];
    [lineView kgn_sizeToWidth:1];
    [lineView kgn_positionToTheLeftOfItem:whiteLogo withOffset:-17];
    [lineView kgn_positionBelowItem:whiteLogo];
    [lineView kgn_positionAboveItem:clockIcon];
    
    UIView *lineView2 = [UIView new];
    lineView2.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    [self.view addSubview:lineView2];
    [lineView2 kgn_sizeToWidth:1];
    [lineView2 kgn_positionToTheLeftOfItem:clockIcon withOffset:-17];
    [lineView2 kgn_positionBelowItem:clockIcon];
    [lineView2 kgn_positionAboveItem:genderIcon];
    
    UILabel *with = [UILabel new];
    with.textColor = [UIColor whiteColor];
    with.backgroundColor = [UIColor clearColor];
    with.textAlignment = NSTextAlignmentCenter;
    with.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
    with.text = @"with";
    [self.view addSubview:with];
    [with sizeToFit];
    [with kgn_positionToTheRightOfItem:genderIcon withOffset:15];
    [with kgn_positionBelowItem:clockIcon withOffset:34];
    
    UIButton *genders = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [genders setBackgroundColor:[UIColor clearColor]];
    genders.tintColor = [UIColor whiteColor];
    [genders setTitle:@"all genders" forState:UIControlStateNormal];
    genders.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:18];
    [genders addTarget:self action:@selector(pickGender) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:genders];
    self.genders = genders;
    [genders kgn_sizeToHeight:25];
    [genders kgn_positionToTheRightOfItem:with withOffset:10];
    [genders kgn_positionBelowItem:clockIcon withOffset:34];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [confirmButton setBackgroundColor:[UIColor whiteColor]];
    confirmButton.tintColor = BounceRed;
    [confirmButton.layer setCornerRadius:10];
    [confirmButton setTitle:@"Find homies nearby!" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:18];
    [confirmButton addTarget:self action:@selector(confirmButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
    [confirmButton kgn_sizeToHeight:50];
    [confirmButton kgn_sizeToWidth:self.view.frame.size.width - 100];
    [confirmButton kgn_centerHorizontallyInSuperview];
    [confirmButton kgn_pinToBottomEdgeOfSuperviewWithOffset:15 + TAB_BAR_HEIGHT];
    
    self.location_manager = [[CLLocationManager alloc] init];

    if (IS_IOS8) {
        [self.location_manager requestAlwaysAuthorization];
    }

    self.location_manager.pausesLocationUpdatesAutomatically = YES;
    self.location_manager.activityType = CLActivityTypeFitness;
    
    if ([PFUser currentUser] == nil) {
        LoginUser(self);
    }
    
    [self.view setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    
    // single tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDate:)];
    tapGestureRecognize.numberOfTapsRequired = 1;
    [tapGestureRecognize setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGestureRecognize];
    
    UIView *shadowView = [UIView new];
    [shadowView.layer setShadowColor:[UIColor blackColor].CGColor];
    [shadowView.layer setShadowOffset:CGSizeMake(0, 5)];
    [shadowView.layer setShadowRadius:10.0];
    [shadowView.layer setShadowOpacity:0.16];
    shadowView.clipsToBounds = NO;
    shadowView.layer.masksToBounds = NO;
    [self.view addSubview:shadowView];
    [shadowView kgn_sizeToHeight:250];                             // TODO: ADJUST THIS
    [shadowView kgn_sizeToWidth:self.view.frame.size.width - 40];
    [shadowView kgn_positionBelowItem:selectHP withOffset:10];
    [shadowView kgn_centerHorizontallyInSuperview];
    shadowView.backgroundColor = [UIColor whiteColor];
    self.shadowView = shadowView;
    self.shadowView.hidden = true;
    
    UITableView *tableView = [UITableView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.hidden = YES;
    tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    [tableView kgn_sizeToHeight:250];                             // TODO: ADJUST THIS
    [tableView kgn_sizeToWidth:self.view.frame.size.width - 40];
    [tableView kgn_positionBelowItem:selectHP withOffset:10];
    [tableView kgn_centerHorizontallyInSuperview];
    self.tableView = tableView;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.timeAllocated = 120;
    if ([GlobalVariables shouldNotOpenRequestView]) {
        [self setBarButtonItemLeft:@"common_back_button"];
    }
    
    if (![GlobalVariables shouldNotOpenRequestView]) {

        NSUInteger numValidRequests = [[ParseManager getInstance] getNumberOfValidRequests];
        NSLog(@"%lu", (unsigned long)numValidRequests);
        
        if (numValidRequests > 0) {
            RequestsViewController *requestsViewController = [RequestsViewController new];
            requestsViewController.delegate = self.delegate;
            [self.navigationController pushViewController:requestsViewController animated:true];
        }
    }

    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [self startReceivingSignificantLocationChanges];
        [self changeCenterToUserLocation];
        [self setUserTrackingMode];
    }

    if ([[RequestManger getInstance] hasActiveRequest]) {
        NSLog(@"SHOULD PRESENT NOW");
    }
}

// Sets left nav bar button
-(void) setBarButtonItemLeft:(NSString*) imageName {
    UIImage *menuImage = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(cancelButtonClicked)];
}

// Sets nav bar button item with image
-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action {
    
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}

-(void)cancelButtonClicked {
    RequestsViewController *requestsViewController = [RequestsViewController new];
    requestsViewController.delegate = self.delegate;
    [self.navigationController pushViewController:requestsViewController animated:true];
}

- (void) requestsViewControllerDidRequestDismissal:(RequestsViewController *)controller withCompletion:(void (^)())completion {
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (completion) {
            completion();
        }
    }];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[RequestManger getInstance] setRequestManagerDelegate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark Custom Functions
- (void)startReceivingSignificantLocationChanges {
    if (nil == self.location_manager) {
        self.location_manager = [[CLLocationManager alloc] init];
    }
    
    self.location_manager.delegate = self;
    self.location_manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.location_manager.distanceFilter = 100; // meters.. not sure if this will work well?
    [self.location_manager startMonitoringSignificantLocationChanges];
}

- (void)setUserTrackingMode {
    [self.map setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)changeCenterToUserLocation {
    MKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(self.location_manager.location.coordinate.latitude,
                                               self.location_manager.location.coordinate.longitude);
    MKCoordinateSpan span;
    span.latitudeDelta = 0.1;
    span.longitudeDelta = 0.1;
    
    region.span = span;
    [self.map setRegion:region];
}

/// Called when a significant location change occurs.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self foundLocation:manager.location];
}

/// Called when an error occurs
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager failed with error: %@", error);
}

/// Called when the location is updated.
- (void)foundLocation:(CLLocation *)location
{
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:location];
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"CurrentLocation"] = geoPoint;
    [currentUser saveInBackground];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *reuseId = @"pin";
    MKPinAnnotationView *pav = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (pav == nil) {
        pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pav.draggable = YES;
        pav.canShowCallout = YES;
    }
    else {
        pav.annotation = annotation;
    }
    return pav;
}

- (IBAction)messageButtonClicked:(id)sender {
    MessageScreenViewController* messageScreenViewController = [[MessageScreenViewController alloc] init];
    messageScreenViewController.genderMatching = self.genderMatching;
    messageScreenViewController.timeAllocated = self.timeAllocated;
    [self.navigationController pushViewController:messageScreenViewController animated:NO];
}

- (IBAction)groupsChatButtonClicked:(id)sender {
    GroupsListViewController *groupsListViewController = [[GroupsListViewController alloc] init];
    [self.navigationController pushViewController:groupsListViewController animated:YES];
}

- (void)didEndRequestWithError:(NSError *)error
{
    [[Utility getInstance] hideProgressHud];
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
            // calculate the distance to the group
            self.nearUsers = [[NSMutableArray alloc] init];
            self.homepointImages = [NSMutableArray new];
            self.homepointDistances = [NSMutableArray new];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (PFObject *group in groups) {
                    [self.nearUsers addObject:[NSNumber numberWithInteger:[[ParseManager getInstance] getNearUsersNumberInGroup:group]]];
                    
                    // Get distance label
                    double distance = [[ParseManager getInstance] getDistanceToGroup:group];
                    NSString *distanceLabel = @"";

                    if (distance > 2500) {
                        distance = distance*0.000189394;
                        
                        if (distance >= 500) {
                            distanceLabel = @"500+ miles away";
                        }
                        else {
                            distanceLabel = [NSString stringWithFormat:DISTANCE_MESSAGE_IN_MILES, distance];
                        }
                    }
                    else {
                        distanceLabel = [NSString stringWithFormat:DISTANCE_MESSAGE_IN_FEET, (int)distance];
                    }
                    
                    [self.homepointDistances addObject:distanceLabel];
                    
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

- (void) confirmButtonClicked {
    
    self.selectedGroups = [NSMutableArray new];
    if (self.timeAllocated == 0) self.timeAllocated = 120;
    
    for (int i = 0; i < self.selectedCells.count; i++) {
        if ([[self.selectedCells objectAtIndex:i] boolValue]) { // if selected
            [self.selectedGroups addObject:[self.groups objectAtIndex:i]];
        }
    }
    
    if (![self.selectedGroups count]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please select a homepoint!"
                                                             message:@"A homepoint is a group of your neighbors within an area. Only people who are a part of the homepoint you select will receive your message."
                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self creatMessageRequestToSelectedGroup:self.selectedGroups];
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
            RequestsViewController *requestsViewController = [RequestsViewController new];
            requestsViewController.delegate = self.delegate;
            [self.navigationController pushViewController:requestsViewController animated:true];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
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


#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"homepointCell";
    HomepointDropdownCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [HomepointDropdownCell new];
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
                    cell.hpImage.image = image;
                    cell.hpImage.contentMode = UIViewContentModeScaleToFill;
                    cell.hpImage.backgroundColor = [UIColor blackColor]; // this should never show
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
    
    
    NSString *usersNearby = [self.nearUsers objectAtIndex:indexPath.row];
    int numUsers = (int)[usersNearby integerValue];
    if (numUsers == 0) {
        cell.nearbyUsers.text = @"no users nearby :(";
    }
    else if (numUsers == 1) {
        cell.nearbyUsers.text = [NSString stringWithFormat:@"1 user nearby"];
    }
    else if (numUsers != 0) {
        cell.nearbyUsers.text = [NSString stringWithFormat:@"%@ users nearby",usersNearby];
    }
    
    NSString *distanceText = [self.homepointDistances objectAtIndex:indexPath.row];
    cell.distanceLabel.text = distanceText;
    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectedCells.count > 0) {
        for (int i = 0; i < [self.selectedCells count]; i++) {
            [self.selectedCells replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
        }
            [self.selectedCells replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
        
            self.selectHP.tintColor = [UIColor whiteColor];
            [self.selectHP setTitle:[[self.groups objectAtIndex:indexPath.row] objectForKey:PF_GROUPS_NAME] forState:UIControlStateNormal];
            self.tableView.hidden = true;
            self.shadowView.hidden = true;
        }
        //[self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

-(void)showDropDown {
    BOOL shouldHide = !self.tableView.hidden;
    
    if (self.tableView.hidden) {
        self.tableView.hidden = shouldHide;
        self.shadowView.hidden = shouldHide;
    }

    double originalOpacity = shouldHide ? 1.0 : 0.0;
    double newOpacity = shouldHide ? 0.0 : 1.0;

    self.tableView.layer.opacity = originalOpacity;
    self.shadowView.layer.opacity = originalOpacity;
    [UIView animateWithDuration:0.15f animations: ^void() {
        self.shadowView.layer.opacity = newOpacity;
        self.tableView.layer.opacity = newOpacity;
    } completion:^(BOOL finishedCompletion) {
        if (shouldHide) {
            self.shadowView.hidden = shouldHide;
            self.tableView.hidden = shouldHide;
        }
    }];
}

- (void) pickGender {
    if (!_imageActionSheet) {
        self.imageActionSheet = [[UIActionSheet alloc] initWithTitle:@"We'll pair you with those you feel most comfortable with, from your homepoint."  delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"All genders", @"Others of your gender", nil];
    }
    [self.imageActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0) {
        self.genderMatching = ALL_GENDER;
        self.genders.tintColor = [UIColor whiteColor];
        [self.genders setTitle:@"all genders" forState:UIControlStateNormal];
    }
    else if (buttonIndex == 1) {
        PFUser* u = [PFUser currentUser];
        self.genderMatching = u[PF_GENDER];
        self.genders.tintColor = [UIColor whiteColor];
        [self.genders setTitle:@"others of my gender" forState:UIControlStateNormal];
    }
    else {
        // cancel
    }
}

-(void)pickTime {
    if (self.datePicker.hidden == YES) {
        self.datePicker.hidden = NO;
    } else {
        UIDatePicker *pickerView = [[UIDatePicker alloc] init];
        pickerView.datePickerMode = UIDatePickerModeCountDownTimer;
        pickerView.minuteInterval = 5;
        pickerView.backgroundColor = [UIColor whiteColor];

        // Default of 2 hours
        NSInteger seconds = 7200;
        
        [pickerView setCountDownDuration:seconds];
        [self.view addSubview:pickerView];
        self.datePicker = pickerView;
        [pickerView kgn_sizeToWidth:self.view.frame.size.width];
        [pickerView kgn_pinToLeftEdgeOfSuperview];
        [pickerView kgn_pinToBottomEdgeOfSuperviewWithOffset:TAB_BAR_HEIGHT];
    }
}

- (void)dismissDate:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.datePicker.hidden) {
        self.datePicker.hidden = YES;
        NSTimeInterval duration = self.datePicker.countDownDuration;
        int hours = (int)(duration/3600.0f);
        int minutes = ((int)duration - (hours * 3600))/60;
        self.timeAllocated = hours*60 + minutes;
        self.time.tintColor = [UIColor whiteColor];
        
        // Initial case
        if (hours == 0 && minutes == 0) {
            [self.time setTitle:[NSString stringWithFormat:@"2 hours & 0 min"] forState:UIControlStateNormal];
        } else {
            [self.time setTitle:[NSString stringWithFormat:@"%d hours & %d min", hours, minutes] forState:UIControlStateNormal];
        }
    }
}

@end
