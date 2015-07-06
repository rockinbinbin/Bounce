//
//  HomeScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "HomeScreenViewController.h"
#import <Parse/Parse.h>
#import "utilities.h"
#import "MessageScreenViewController.h"
#import "RequestsViewController.h"
#import "AppConstant.h"
#import "GroupsListViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "RequestManger.h"

@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController

# pragma mark Builtin Functions

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[RequestManger getInstance] loadActiveRequest];
    
    // initialize incase no controls are touched
    self.genderMatching = ALL_GENDER;
    self.timeAllocated = 5.0;
    
    self.map = [[MKMapView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.map];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.frame = CGRectMake(0, self.view.frame.size.height - self.view.frame.size.height/3.5, self.view.frame.size.width, self.view.frame.size.height/3.5);
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bottomView];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"All genders", @"Gender matching", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    segmentedControl.tintColor = BounceSeaGreen;
    segmentedControl.frame = CGRectMake(50, 20, self.view.frame.size.width - 100, 30);
    [segmentedControl addTarget:self action:@selector(MySegmentControlAction:) forControlEvents: UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 1;
    [self.bottomView addSubview:segmentedControl];
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = BounceRed;
    self.navigationController.navigationBar.translucent = NO;

    self.repliesView = [[UIView alloc] init];
    self.repliesView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3);
    self.repliesView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.map addSubview:self.repliesView];
    
    
    self.repliesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.repliesButton.frame = CGRectMake(self.repliesView.frame.origin.x + 65, self.repliesView.frame.origin.y + 40, self.repliesView.frame.size.width/1.5, self.repliesView.frame.size.height/4);
    [self.repliesButton setTitle:@"Coordinate trip home" forState:UIControlStateNormal];
    self.repliesButton.titleLabel.font = [UIFont fontWithName:@"Quicksand-Bold" size:18.0f];
    self.repliesButton.backgroundColor = BounceRed;
    self.repliesButton.tintColor = [UIColor whiteColor];
    self.repliesButton.layer.cornerRadius = 10;
    self.repliesButton.clipsToBounds = YES;
    [self.repliesButton addTarget:self action:@selector(repliesButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.repliesView addSubview:self.repliesButton];
    
    self.timeLeftLabel = [[UILabel alloc] init];
    self.timeLeftLabel.frame = CGRectMake(self.repliesView.frame.origin.x + 120, self.repliesView.frame.origin.y + 120, self.repliesView.frame.size.width/1.5, self.repliesView.frame.size.height/4);
    self.timeLeftLabel.textColor = [UIColor whiteColor];
    self.timeLeftLabel.font = [UIFont fontWithName:@"Avenir-Next" size:11];
    [self.repliesView addSubview:self.timeLeftLabel];
    
    // round number of message label
    [self.numOfMessagesLabel setFont:[UIFont fontWithName: @"Quicksand-Regular" size: 16.0f]];
    self.numOfMessagesLabel.layer.cornerRadius = self.numOfMessagesLabel.frame.size.height/2;
    self.numOfMessagesLabel.layer.masksToBounds = YES;
    self.numOfMessagesLabel.backgroundColor = [UIColor redColor];
    
    CGRect frame = CGRectMake(60, 80, 250.0, 10.0);
    UISlider *slider = [[UISlider alloc] initWithFrame:frame];
    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [slider setBackgroundColor: [UIColor clearColor]];
    slider.minimumValue = 5.0;
    slider.maximumValue = 120.0;
    slider.continuous = YES;
    slider.value = 25.0;
    [slider setMinimumTrackTintColor:BounceSeaGreen];
    [self.bottomView addSubview:slider];
    
    UILabel *navLabel = [[UILabel alloc]init];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"Quicksand-Regular" size:28.0f];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"bounce";
    [navLabel sizeToFit];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.location_manager = [[CLLocationManager alloc] init];
    if (IS_IOS8){
    [self.location_manager requestAlwaysAuthorization];
    }
    self.location_manager.pausesLocationUpdatesAutomatically = YES;
    self.location_manager.activityType = CLActivityTypeFitness;
    
    if ([PFUser currentUser] == nil) {
        LoginUser(self);
    }
    
    CGSize size = self.view.frame.size;
    [self.view setCenter:CGPointMake(size.width/2, size.height/2)];
    
    self.getHomeButton = [[UIButton alloc] init];
    self.getHomeButton.frame = CGRectMake(90, 200, 200, 100);
    UIImage *img = [UIImage imageNamed:@"getHome"];
    [self.getHomeButton setImage:img forState:UIControlStateNormal];
    [self.getHomeButton addTarget:self action:@selector(messageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.map addSubview:self.getHomeButton];
    
    self.endRequestButton = [[UIButton alloc]init];
    self.endRequestButton.frame = CGRectMake(0, self.view.frame.size.height - 108, self.view.frame.size.width, 45);
    self.endRequestButton.tintColor = [UIColor whiteColor];
    self.endRequestButton.backgroundColor = BounceSeaGreen;
    [self.endRequestButton setTitle:@"cancel request" forState:UIControlStateNormal];
    self.endRequestButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Next" size:11];
    [self.endRequestButton addTarget:self action:@selector(endRequestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.map addSubview:self.endRequestButton];
    
    [self startReceivingSignificantLocationChanges];
    [self changeCenterToUserLocation];
    [self setUserTrackingMode];
    [self hideReplyView];
}

- (void)MySegmentControlAction:(UISegmentedControl *)segment
{
    if(segment.selectedSegmentIndex == 0)
    {
        self.genderMatching = ALL_GENDER;
        NSLog(@"All genders selected");
    }
    else if (segment.selectedSegmentIndex == 1) {
        PFUser* u = [PFUser currentUser];
        self.genderMatching = u[PF_GENDER];
        NSLog(@"Gender matching selected");
    }
}

-(void)sliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    float value = slider.value;
    self.timeAllocated = value;
    NSLog(@"TIME ALLOCATED");
    NSLog(@"%f", self.timeAllocated);
}


-(void) viewWillAppear:(BOOL)animated{
    [[RequestManger getInstance] setRequestManagerDelegate:self];
    if ([[RequestManger getInstance] hasActiveRequest]) {
        [self requestCreated];
    }
}
- (void) viewWillDisappear:(BOOL)animated
{
    [[RequestManger getInstance] setRequestManagerDelegate:nil];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}
#pragma mark - add left button
- (void) addLeftMenuButton
{
    AMSlideMenuMainViewController *mainVC = [AMSlideMenuMainViewController getInstanceForVC:self];
    
    UINavigationItem *navItem = self.navigationItem;
    
    UIButton *leftBtn = self.leftMenuButton;
    [mainVC configureLeftMenuButton:leftBtn];
    [leftBtn addTarget:mainVC action:@selector(openLeftMenu) forControlEvents:UIControlEventTouchUpInside];
    
    mainVC.leftMenuButton = leftBtn;
    
    navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftMenuButton];
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
    NSLog(@"location called");
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
    [self.navigationController pushViewController:messageScreenViewController animated:YES];
}

- (IBAction)repliesButtonClicked:(id)sender {
    // navigate to the request screen
    RequestsViewController* requestsViewController = [[RequestsViewController alloc] initWithNibName:@"RequestsViewController" bundle:nil];
    [self.navigationController pushViewController:requestsViewController animated:YES];
}
- (IBAction)endRequestButtonClicked:(id)sender {
    // call the request manager
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [[Utility getInstance] showProgressHudWithMessage:@"End Request..." withView:self.view];
        [[RequestManger getInstance] setRequestManagerDelegate:self];
        [[RequestManger getInstance] endRequest];
    }
}
- (IBAction)privateChatButtonClicked:(id)sender {
    // FIRST CALL THE PARSE MANAGER METHOD TO CALC THE CHAT NUMBER
    [[ParseManager getInstance] getNumberOfValidRequests];
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC openLeftMenu];
}

- (IBAction)groupsChatButtonClicked:(id)sender {
    GroupsListViewController *groupsListViewController = [[GroupsListViewController alloc] init];
    [self.navigationController pushViewController:groupsListViewController animated:YES];
}

#pragma mark - RequestManger Delegate
- (void)updateRequestRemainingTime:(NSInteger)remainingTime
{
    @try {
        [self showTheReplyView];
        self.timeLeftLabel.text  = [NSString stringWithFormat:REQUEST_TIME_REMAINING_STRING, (long)remainingTime];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

- (void)updateRequestUnreadMessage:(NSInteger)numberOfUnreadMessages
{
    @try {
        if (numberOfUnreadMessages > 0) {
            [self.numOfMessagesLabel setHidden:NO];
            [self.numOfMessagesLabel setText:[NSString stringWithFormat:@"%li", (long)numberOfUnreadMessages]];
        }
        else {
            [self.numOfMessagesLabel setHidden:YES];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
- (void)didEndRequestWithError:(NSError *)error
{
    [[Utility getInstance] hideProgressHud];
    if (!error) {
        [self hideReplyView];
    }
}
- (void)requestTimeOver
{
    [self hideReplyView];
}
- (void)requestCreated
{
    self.timeLeftLabel.text  = [NSString stringWithFormat:REQUEST_TIME_REMAINING_STRING, (long)[[RequestManger getInstance] requestLeftTimeInMinute]];
    [self showTheReplyView];
}
#pragma mark - show Reply view
- (void) showTheReplyView
{
    [self.repliesView setHidden:NO];
    [self.getHomeButton setHidden:YES];
    [self.bottomView setHidden:YES];
    [self.endRequestButton setHidden:NO];
    [self.timeLeftLabel setHidden:NO];
}
- (void) hideReplyView
{
    [self.repliesView setHidden:YES];
    [self.numOfMessagesLabel setHidden:YES];
    [self.getHomeButton setHidden:NO];
    [self.bottomView setHidden:NO];
    [self.endRequestButton setHidden:YES];
    [self.timeLeftLabel setHidden:YES];
}

#pragma mark - MKOverlay Delegate


@end
