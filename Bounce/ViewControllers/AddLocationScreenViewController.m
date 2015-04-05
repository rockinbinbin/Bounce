//
//  AddLocationScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/31/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "AddLocationScreenViewController.h"
#import "AddGroupUsersViewController.h"
#import "AppConstant.h"
#import <Parse/Parse.h>
#import "ParseManager.h"
#import <CoreLocation/CoreLocation.h>
#import "UIViewController+AMSlideMenu.h"
@interface AddLocationScreenViewController ()

@end

@implementation AddLocationScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dontAddLocationButton.backgroundColor = DEFAULT_COLOR;
    [self setBarButtonItemLeft:@"common_back_button"];
    self.navigationItem.title = @"set location";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(doneButtonClicked)];
    doneButton.tintColor = DEFAULT_COLOR;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapClicked:)];
    
    tapRecognizer.numberOfTapsRequired = 1;
    
    tapRecognizer.numberOfTouchesRequired = 1;
    
    [self.map addGestureRecognizer:tapRecognizer];

    [self startReceivingSignificantLocationChanges];
    [self changeCenterToUserLocation];
    [self setUserTrackingMode];
}
- (void) viewWillAppear:(BOOL)animated{
    // Disable left Slide menu
    [self disableSlidePanGestureForLeftMenu];
}
-(IBAction)mapClicked:(UITapGestureRecognizer *)recognizer
{
    CGPoint clickedPoint = [recognizer locationInView:self.map];
    
    CLLocationCoordinate2D tapPoint = [self.map convertPoint:clickedPoint toCoordinateFromView:self.map];
    
    MKPointAnnotation *mkPointClicked = [[MKPointAnnotation alloc] init];
    
    mkPointClicked.coordinate = tapPoint;
    NSLog(@"%f , %f", clickedPoint.x, clickedPoint.y);
    NSLog(@"%f", mkPointClicked.coordinate.latitude);
    NSLog(@"%f", mkPointClicked.coordinate.longitude);
    
    MKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(mkPointClicked.coordinate.latitude,
                                               mkPointClicked.coordinate.longitude);
    MKCoordinateSpan span;
    span.latitudeDelta = 0.1;
    span.longitudeDelta = 0.1;
    
    region.span = span;
    NSArray *existingpoints = self.map.annotations;
    if ([existingpoints count])
        [self.map removeAnnotations:existingpoints];
    [self.map addAnnotation:mkPointClicked];
    self.groupLocation = [PFGeoPoint geoPointWithLatitude:mkPointClicked.coordinate.latitude longitude:mkPointClicked.coordinate.longitude];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName{
    UIImage *menuImage = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(cancelButtonClicked)];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}

-(void)cancelButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneButtonClicked{
    if (self.groupLocation) {
        [self navigateToHomeGroupsAndSetItsData];
    }
    else{
        UIAlertView *emptyLocation = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                message:@"Make sure you set the group location!"
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [emptyLocation show];
    }
}

- (IBAction)dontAddLocationButtonClicked:(id)sender {
    //TODO: set the location in the new view controller!
    self.groupLocation = [PFUser currentUser][@"CurrentLocation"];

    [self navigateToHomeGroupsAndSetItsData];
}

-(void) navigateToHomeGroupsAndSetItsData{
    AddGroupUsersViewController *contoller = [[AddGroupUsersViewController alloc]  init];
    NSMutableArray *users  = [[NSMutableArray alloc] initWithArray:[[ParseManager getInstance] getAllUsers]];
    PFUser *currentUser = [PFUser currentUser];
    // move the current user to the first cell
    [users removeObject:currentUser];
    [users insertObject:currentUser atIndex:0];

    contoller.groupUsers = [NSArray arrayWithArray:users];
    contoller.groupLocation = self.groupLocation;
    contoller.groupPrivacy = self.groupPrivacy;
    contoller.groupName = self.groupName;
    [self.navigationController pushViewController:contoller animated:YES];
}

# pragma mark Custom Functions

/// MODIFIES: The location manager
/// EFFECTS:  Starts the Core Location manager monitoring for significant
///           location changes, to preserve battery life.
- (void)startReceivingSignificantLocationChanges {
    if (nil == self.location_manager) {
        self.location_manager = [[CLLocationManager alloc] init];
    }
    
    self.location_manager.delegate = self;
    [self.location_manager startMonitoringSignificantLocationChanges];
}

/// MODIFIES: self.map
/// EFFECTS:  Sets the user tracking mode to be constantly set around the
///           user.
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

@end
