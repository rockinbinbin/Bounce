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

@property (strong, nonatomic) CLLocationManager *location_manager;
@property (weak, nonatomic) UILabel *timeRemainingLabel;
@property (weak, nonatomic) MKMapView *map;
@property (weak, nonatomic) UIView *repliesView;
@property (weak, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UIButton *getHomeButton;
@property (weak, nonatomic) UIButton *leftMenuButton;
@property (weak, nonatomic) NSString *genderMatching;
@property (nonatomic) float timeAllocated;
@property (weak, nonatomic) UILabel *numOfMessagesLabel;

@end

@implementation HomeScreenViewController

# pragma mark Builtin Functions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = BounceRed;
    self.navigationController.navigationBar.translucent = NO;
    
    
    [[RequestManger getInstance] loadActiveRequest];
    
    self.genderMatching = ALL_GENDER;
    self.timeAllocated = 5.0;
    
    MKMapView *tempMap = [[MKMapView alloc] initWithFrame:self.view.frame];
    tempMap.scrollEnabled = NO;
    [self.view addSubview:tempMap];
    self.map = tempMap;
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.frame = CGRectMake(0, self.view.frame.size.height - self.view.frame.size.height/3.5, self.view.frame.size.width, self.view.frame.size.height/5.3);
    bottomView.backgroundColor = [UIColor whiteColor];
    bottomView.layer.borderColor = BounceSeaGreen.CGColor;
    bottomView.layer.borderWidth = 3.0f;
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"All genders", @"Gender matching", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    segmentedControl.tintColor = BounceSeaGreen;
    segmentedControl.frame = CGRectMake(50, 15, self.view.frame.size.width - 100, 30);
    [segmentedControl addTarget:self action:@selector(MySegmentControlAction:) forControlEvents: UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 1;
    [self.bottomView addSubview:segmentedControl];

    UIView *replies = [[UIView alloc] init];
    replies.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3);
    replies.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.map addSubview:replies];
    self.repliesView = replies;
    
    UIButton *repliesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    repliesButton.frame = CGRectMake(self.repliesView.frame.origin.x + 65, self.repliesView.frame.origin.y + 40, self.repliesView.frame.size.width/1.5, self.repliesView.frame.size.height/4);
    [repliesButton setTitle:@"Coordinate trip home" forState:UIControlStateNormal];
    repliesButton.titleLabel.font = [UIFont fontWithName:@"Quicksand-Bold" size:18.0f];
    repliesButton.backgroundColor = BounceRed;
    repliesButton.tintColor = [UIColor whiteColor];
    repliesButton.layer.cornerRadius = 10;
    repliesButton.clipsToBounds = YES;
    [repliesButton addTarget:self action:@selector(repliesButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.repliesView addSubview:repliesButton];
    
    UILabel *timeLeftLabel = [[UILabel alloc] init];
    timeLeftLabel.frame = CGRectMake(self.repliesView.frame.origin.x + 120, self.repliesView.frame.origin.y + 120, self.repliesView.frame.size.width/1.5, self.repliesView.frame.size.height/4);
    timeLeftLabel.textColor = [UIColor whiteColor];
    timeLeftLabel.font = [UIFont fontWithName:@"Avenir-Next" size:11];
    [self.repliesView addSubview:timeLeftLabel];
    self.timeRemainingLabel = timeLeftLabel;
    
    // TODO: TEST NOTIFICATION VIEW
    UILabel *numOfMessagesLabel = [[UILabel alloc] init];
    [numOfMessagesLabel setFont:[UIFont fontWithName: @"Avenir-Next" size: 16.0f]];
    numOfMessagesLabel.layer.cornerRadius = self.numOfMessagesLabel.frame.size.height/2;
    numOfMessagesLabel.layer.masksToBounds = YES;
    numOfMessagesLabel.textColor = [UIColor redColor];
    self.numOfMessagesLabel = numOfMessagesLabel;
    [self.repliesView addSubview:numOfMessagesLabel];
    numOfMessagesLabel.frame = CGRectMake(repliesButton.frame.origin.x + repliesButton.frame.size.width, repliesButton.frame.origin.y, 5, 5);
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(60, 85, 250.0, 10.0)];
    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    slider.maximumValue = 120;
    slider.minimumValue = 5.0;
    slider.continuous = YES;
    slider.value = 30.0;
    [slider setMinimumTrackTintColor:BounceSeaGreen];
    [self.bottomView addSubview:slider];
    
    UILabel *leavingIn = [[UILabel alloc]init];
    leavingIn.textColor = [UIColor blackColor];
    leavingIn.backgroundColor = [UIColor clearColor];
    leavingIn.textAlignment = NSTextAlignmentCenter;
    leavingIn.font = [leavingIn.font fontWithSize:11.0f];
    leavingIn.text = @"Leaving in...";
    leavingIn.frame = CGRectMake(slider.frame.origin.x - 27, slider.frame.origin.y - 70, 100, 100);
    [bottomView addSubview:leavingIn];
      
    UILabel *twohr = [[UILabel alloc]init];
    twohr.textColor = [UIColor blackColor];
    twohr.backgroundColor = [UIColor clearColor];
    twohr.textAlignment = NSTextAlignmentCenter;
    twohr.font = [twohr.font fontWithSize:11.0f];
    twohr.text = @"2 hrs";
    twohr.frame = CGRectMake(slider.frame.origin.x + slider.frame.size.width , slider.frame.origin.y - 20, 30, 50);
    [bottomView addSubview:twohr];
    
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
    
    [self.view setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    
    UIButton *getHomeButton = [[UIButton alloc] init];
    getHomeButton.frame = CGRectMake(90, 200, 200, 100);
    UIImage *img = [UIImage imageNamed:@"getHome"];
    [getHomeButton setImage:img forState:UIControlStateNormal];
    [getHomeButton addTarget:self action:@selector(messageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.map addSubview:getHomeButton];
    self.getHomeButton = getHomeButton;
    
    UIButton *endRequestButton = [[UIButton alloc]init];
    endRequestButton.frame = CGRectMake(0, self.view.frame.size.height - 108, self.view.frame.size.width, 45);
    endRequestButton.tintColor = [UIColor whiteColor];
    endRequestButton.backgroundColor = BounceSeaGreen;
    [endRequestButton setTitle:@"cancel request" forState:UIControlStateNormal];
    endRequestButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Next" size:11];
    [endRequestButton addTarget:self action:@selector(endRequestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.map addSubview:endRequestButton];
    
    [self startReceivingSignificantLocationChanges];
    [self changeCenterToUserLocation];
    [self setUserTrackingMode];
    [self hideReplyView];
}

- (void)MySegmentControlAction:(UISegmentedControl *)segment {
    if(segment.selectedSegmentIndex == 0) {
        self.genderMatching = ALL_GENDER;
    }
    else if (segment.selectedSegmentIndex == 1) {
        PFUser* u = [PFUser currentUser];
        self.genderMatching = u[PF_GENDER];
    }
}

-(void)sliderAction:(id)sender {
    UISlider *slider = (UISlider*)sender;
    float value = slider.value;
    self.timeAllocated = value;
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to cancel the request?"
                                                    message:@"All of the recepients will be notified."
                                                   delegate:self
                                          cancelButtonTitle:@"End Request"
                                          otherButtonTitles:@"Don't End", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"End Request..." withView:self.view];
            [[RequestManger getInstance] setRequestManagerDelegate:self];
            [[RequestManger getInstance] endRequest];
        }
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
        self.timeRemainingLabel.text  = [NSString stringWithFormat:REQUEST_TIME_REMAINING_STRING, (long)remainingTime];
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
    self.timeRemainingLabel.text  = [NSString stringWithFormat:REQUEST_TIME_REMAINING_STRING, (long)[[RequestManger getInstance] requestLeftTimeInMinute]];
    [self showTheReplyView];
}
#pragma mark - show Reply view
- (void) showTheReplyView
{
    [self.repliesView setHidden:NO];
    [self.getHomeButton setHidden:YES];
    [self.bottomView setHidden:YES];
}
- (void) hideReplyView
{
    [self.repliesView setHidden:YES];
    [self.numOfMessagesLabel setHidden:YES];
    [self.getHomeButton setHidden:NO];
    [self.bottomView setHidden:NO];
}

#pragma mark - MKOverlay Delegate


@end
