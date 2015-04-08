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
#import "Utility.h"

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
    [self.map setDelegate:self];

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
        [self getAllUsers];
    }
    else{
        [[Utility getInstance] showAlertMessage:@"Make sure you set the group location!"];
    }
}

- (IBAction)dontAddLocationButtonClicked:(id)sender {
    //TODO: set the location in the new view controller!
    self.groupLocation = [PFUser currentUser][@"CurrentLocation"];
    [self getAllUsers];
}
- (void) getAllUsers
{
    [[ParseManager getInstance] setDelegate:self];
    [[ParseManager getInstance] getAllUsers];
}
#pragma mark - Parse Manager Delegate
- (void)didloadAllObjects:(NSArray *)objects
{
    NSMutableArray *users  = [[NSMutableArray alloc] initWithArray:objects];
    PFUser *currentUser = [PFUser currentUser];
    // Add the current user to the first cell
    [users insertObject:currentUser atIndex:0];
    [self navigateToGroupUsersScreenAndSetData:([NSArray arrayWithArray:users])];
 
}
- (void)didFailWithError:(NSError *)error
{
    NSLog(@"Error in loading users from parse.com");
}
-(void) navigateToGroupUsersScreenAndSetData:(NSArray *) users{
    AddGroupUsersViewController *contoller = [[AddGroupUsersViewController alloc]  init];
    contoller.groupUsers = users;
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
#pragma mark - MapView delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            UIView *customView = [self createCustomPinAnnotaionView];
            customView.center = pinView.center;
            [pinView addSubview:customView];

        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

#pragma mark - Create Custom view pin annotaion
- (UIView*) createCustomPinAnnotaionView
{
    @try {
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0 , 0, INNER_VIEW_ICON_RADIUS, INNER_VIEW_ICON_RADIUS)];
        // circular icon view
        UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, INNER_VIEW_RADIUS, INNER_VIEW_RADIUS)];
        [imageview setContentMode:UIViewContentModeScaleToFill];
        imageview.image = [UIImage imageNamed:@"common_app_logo"];
        innerView.backgroundColor = DEFAULT_COLOR;
        // Add icon image to the inner view
        imageview.center = innerView.center;
        [innerView addSubview:imageview];
        [[Utility getInstance] addRoundedBorderToView:innerView];
        //Outer view
        UIView *outerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, OUTER_VIEW_RADIUS, OUTER_VIEW_RADIUS)];
        outerView.backgroundColor = CUSTOM_ANNOTAION_OVERLAY_COLOR;
        [[Utility getInstance] addRoundedBorderToView:outerView];
        // Add inner view to the outer view
        innerView.center = outerView.center;
        [outerView addSubview:innerView];
        return outerView;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

@end
