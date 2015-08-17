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

@interface HomeScreenViewController ()

@property (strong, nonatomic) CLLocationManager *location_manager;
@property (weak, nonatomic) MKMapView *map;
@property (weak, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UIButton *getHomeButton;
@property (weak, nonatomic) UIButton *leftMenuButton;
@property (weak, nonatomic) NSString *genderMatching;
@property (nonatomic) float timeAllocated;

@end

@implementation HomeScreenViewController

# pragma mark Builtin Functions

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    navLabel.font = [UIFont fontWithName:@"Quicksand-Regular" size:30];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"bounce";
    [navLabel sizeToFit];
    
    [[RequestManger getInstance] loadActiveRequest];
    
    self.genderMatching = ALL_GENDER;
    self.timeAllocated = 5.0;
    
    MKMapView *tempMap = [MKMapView new];
    tempMap.scrollEnabled = NO;
    [self.view addSubview:tempMap];
    [tempMap kgn_pinToEdgesOfSuperview];
    self.map = tempMap;
    
    UIView *bottomView = [UIView new];
    bottomView.backgroundColor = [UIColor whiteColor];
    bottomView.layer.borderColor = BounceSeaGreen.CGColor;
    bottomView.layer.borderWidth = 3.0f;
    [self.view addSubview:bottomView];
    [bottomView kgn_pinToBottomEdgeOfSuperview];
    [bottomView kgn_sizeToHeight:self.view.frame.size.height/4.9];
    [bottomView kgn_sizeToWidth:self.view.frame.size.width];
    self.bottomView = bottomView;
    UIPanGestureRecognizer *gesture = [UIPanGestureRecognizer new];
    gesture.delegate = self;
    [self.bottomView addGestureRecognizer:gesture];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"All genders", @"Gender matching", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    segmentedControl.tintColor = BounceSeaGreen;
    [segmentedControl addTarget:self action:@selector(MySegmentControlAction:) forControlEvents: UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
    [self.bottomView addSubview:segmentedControl];
    [segmentedControl kgn_sizeToWidth:self.view.frame.size.width - 100];
    [segmentedControl kgn_sizeToHeight:self.view.frame.size.height/20];
    [segmentedControl kgn_centerHorizontallyInSuperview];
    [segmentedControl kgn_pinToTopEdgeOfSuperviewWithOffset:self.view.frame.size.height/40];
    
    UISlider *slider = [UISlider new];
    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    slider.maximumValue = 120;
    slider.minimumValue = 5.0;
    slider.continuous = YES;
    slider.value = 30.0;
    self.timeAllocated = slider.value;
    [slider setMinimumTrackTintColor:BounceSeaGreen];
    [self.bottomView addSubview:slider];
    [slider kgn_sizeToWidth:self.view.frame.size.width - 100];
    [slider kgn_sizeToHeight:10];
    [slider kgn_centerHorizontallyInSuperview];
    [slider kgn_pinToBottomEdgeOfSuperviewWithOffset:20];
    
    UILabel *leavingIn = [UILabel new];
    leavingIn.textColor = [UIColor blackColor];
    leavingIn.backgroundColor = [UIColor clearColor];
    leavingIn.textAlignment = NSTextAlignmentCenter;
    leavingIn.font = [leavingIn.font fontWithSize:self.view.frame.size.height/50];
    leavingIn.text = @"Leaving in...";
    [bottomView addSubview:leavingIn];
    [leavingIn sizeToFit];
    [leavingIn kgn_pinTopEdgeToTopEdgeOfItem:slider withOffset:self.view.frame.size.height/18];
    [leavingIn kgn_pinLeftEdgeToLeftEdgeOfItem:slider];
    
    UILabel *twohr = [UILabel new];
    twohr.textColor = [UIColor blackColor];
    twohr.backgroundColor = [UIColor clearColor];
    twohr.textAlignment = NSTextAlignmentCenter;
    twohr.font = [twohr.font fontWithSize:11.0f];
    twohr.text = @"2 hrs";
    [bottomView addSubview:twohr];
    [twohr sizeToFit];
    [twohr kgn_pinTopEdgeToTopEdgeOfItem:slider];
    [twohr kgn_pinRightEdgeToRightEdgeOfItem:slider withOffset:30];
    
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
    
    UIButton *getHomeButton = [UIButton new];
    UIImage *img = [UIImage imageNamed:@"getHome"];
    [getHomeButton setImage:img forState:UIControlStateNormal];
    [getHomeButton addTarget:self action:@selector(messageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.map addSubview:getHomeButton];
    [getHomeButton kgn_sizeToWidth:200];
    [getHomeButton kgn_sizeToHeight:100];
    [getHomeButton kgn_centerHorizontallyInSuperview];
    [getHomeButton kgn_centerVerticallyInSuperviewWithOffset:-45];
    self.getHomeButton = getHomeButton;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[ParseManager getInstance] returnNumberOfValidRequestsWithNavigationController:self.navigationController];
    
    [self.delegate setScrolling:true];
    
    if (![GlobalVariables shouldNotOpenRequestView]) {
        NSUInteger numValidRequests = [[ParseManager getInstance] getNumberOfValidRequests];
        NSLog(@"%lu", (unsigned long)numValidRequests);
        
        if (numValidRequests > 0) {
            RequestsViewController *requestsViewController = [RequestsViewController new];
            requestsViewController.delegate = self.delegate;
            
            [self.navigationController pushViewController:requestsViewController animated:true];
        }
    }

    [self startReceivingSignificantLocationChanges];
    [self changeCenterToUserLocation];
    [self setUserTrackingMode];


    if ([[RequestManger getInstance] hasActiveRequest]) {
        NSLog(@"SHOULD PRESENT NOW");
    }
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
    [self.delegate setScrolling:false];
    [[RequestManger getInstance] setRequestManagerDelegate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark Custom Methods

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
    [self.navigationController pushViewController:messageScreenViewController animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"End Request..." withView:self.view];
            [[RequestManger getInstance] endRequest];
        }
    }
}

- (IBAction)groupsChatButtonClicked:(id)sender {
    GroupsListViewController *groupsListViewController = [[GroupsListViewController alloc] init];
    [self.navigationController pushViewController:groupsListViewController animated:YES];
}

- (void)didEndRequestWithError:(NSError *)error
{
    [[Utility getInstance] hideProgressHud];
}


@end
