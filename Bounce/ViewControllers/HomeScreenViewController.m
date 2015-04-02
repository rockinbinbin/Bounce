//
//  HomeScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "MapViewController.h"
#import <Parse/Parse.h>
#import "utilities.h"
#import "IntroPages.h"
#import "MessageScreenViewController.h"
#import "RequistsViewController.h"
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

    self.repliesButton.layer.cornerRadius = 4;
    self.repliesButton.clipsToBounds = YES;
    self.repliesButton.backgroundColor = DEFAULT_COLOR;
    self.repliesView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    // rounded view on the left
    CGRect userOnlineFrame = CGRectMake(self.repliesButton.frame.origin.x + 8, self.repliesButton.frame.origin.y - 14 , 20, 20);
    self.roundedView = [[UIView alloc] initWithFrame: userOnlineFrame];
    self.roundedView.layer.cornerRadius = 10;
    self.roundedView.layer.masksToBounds = YES;
    self.roundedView.backgroundColor = [UIColor redColor];
    
    // number of messages for the group
    self.numOfMessagesLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5, 0, 30, 20)];
    self.numOfMessagesLabel.textAlignment = NSTextAlignmentCenter;
    self.numOfMessagesLabel.text = @"";
    [self.numOfMessagesLabel setTextColor:[UIColor whiteColor]];
    [self.numOfMessagesLabel setBackgroundColor:[UIColor clearColor]];
    [self.numOfMessagesLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
    [self.roundedView addSubview:self.numOfMessagesLabel];
    [self.repliesView addSubview:self.roundedView];

    
    self.iconView.layer.cornerRadius = self.iconView.frame.size.height / 2;
    self.iconView.clipsToBounds = YES;
    self.iconView.layer.borderWidth = 3.0f;
    self.iconView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.iconView.backgroundColor = DEFAULT_COLOR;
    
//    [self setBarButtonItemLeft:@"nav_bar_profile_menu_icon"];
    //[self setBarButtonItemRight:@"nav_bar_group_icon"];
    self.navigationItem.title = @"bounce";
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
    
    [self startReceivingSignificantLocationChanges];
    [self changeCenterToUserLocation];
    [self setUserTrackingMode];
    [self hideReplyView];
}

-(void) viewWillAppear:(BOOL)animated{
    [[RequestManger getInstance] setRequestManagerDelegate:self];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
//    if ([[RequestManger getInstance] hasActiveRequest]) {
//        [self.repliesView setHidden:NO];
////        // set the replies view data
////        self.numOfMessagesLabel.text = [NSString stringWithFormat:@"%ld", [[RequestManger getInstance] unReadReplies]];
////        self.timeLeftLabel.text = [NSString stringWithFormat:REQUEST_TIME_LEFT_STRING, [[RequestManger getInstance] requestLeftTimeInMinute]];
//    }else{
//        [self.repliesView setHidden:YES];
//    }
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

- (IBAction)messageButtonClicked:(id)sender {
    MessageScreenViewController* messageScreenViewController = [[MessageScreenViewController alloc] initWithNibName:@"MessageScreenViewController" bundle:nil];
    [self.navigationController pushViewController:messageScreenViewController animated:YES];
}

- (IBAction)repliesButtonClicked:(id)sender {
    // navigate to the request screen
    RequistsViewController* requistsViewController = [[RequistsViewController alloc] initWithNibName:@"RequistsViewController" bundle:nil];
    [self.navigationController pushViewController:requistsViewController animated:YES];
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
//    RequistsViewController *requistViewController = [[RequistsViewController alloc] init];
//    [self.navigationController pushViewController:requistViewController animated:YES];
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    [mainVC openLeftMenu];
}

- (IBAction)groupsChatButtonClicked:(id)sender {
    GroupsListViewController *groupsListViewController = [[GroupsListViewController alloc] init];
    [self.navigationController pushViewController:groupsListViewController animated:YES];
}

#pragma mark - RequestManger Delegat
- (void)updateRequestRemainingTime:(NSInteger)remainingTime
{
    @try {
//        if (remainingTime > 0) {
            [self showTheReplyView];
            self.timeLeftLabel.text  = [NSString stringWithFormat:REQUEST_TIME_LEFT_STRING, (long)remainingTime];
//        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

- (void)updateRequestUnreadMessage:(NSInteger)numberOfUnreadMessages
{
    @try {
        if (numberOfUnreadMessages > 0) {
            [self.roundedView setHidden:NO];
            [self.numOfMessagesLabel setText:[NSString stringWithFormat:@"%ld", (long)numberOfUnreadMessages]];
        }else{
            [self.roundedView setHidden:YES];
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
#pragma mark - show Reply view
- (void) showTheReplyView
{
    [self.repliesView setHidden:NO];
}
- (void) hideReplyView
{
    [self.repliesView setHidden:YES];
    [self.roundedView setHidden:YES];
}
@end
