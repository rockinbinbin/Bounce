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

@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController

# pragma mark Builtin Functions

- (void)viewDidLoad {
    
    [super viewDidLoad];
    UIBarButtonItem *ChatButton = [[UIBarButtonItem alloc] initWithTitle:@"Chat" style:UIBarButtonItemStylePlain target:self action:@selector(chatButtonPressed)];
    
    self.navigationItem.leftBarButtonItem = ChatButton;
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.location_manager = [[CLLocationManager alloc] init];
    [self.location_manager requestAlwaysAuthorization];
    self.location_manager.pausesLocationUpdatesAutomatically = YES;
    self.location_manager.activityType = CLActivityTypeFitness;
    
    if ([PFUser currentUser] == nil) {
        LoginUser(self);
    }
    
    [self startReceivingSignificantLocationChanges];
    [self changeCenterToUserLocation];
    [self setUserTrackingMode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)messageButtonClicked:(id)sender {
    MessageScreenViewController* messageScreenViewController = [[MessageScreenViewController alloc] initWithNibName:@"MessageScreenViewController" bundle:nil];
    [self.navigationController pushViewController:messageScreenViewController animated:YES];
}

- (IBAction)chatButtonPressed:(id)sender {
//TODO: add the chat
    RequistsViewController *requistViewController = [[RequistsViewController alloc] init];
    [self.navigationController pushViewController:requistViewController animated:YES];
}


@end
