//
//  HomeViewController.m
//  hobble.1.1
//
//  Created by Steven on 1/18/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "utilities.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

# pragma mark Builtin Functions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.location_manager = [[CLLocationManager alloc] init];
    [self.location_manager requestWhenInUseAuthorization];
    
    
    [self startReceivingSignificantLocationChanges];
    [self changeCenterToUserLocation];
    [self setUserTrackingMode];
    
    [self.location_manager startUpdatingLocation];
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

// Wait for location callbacks
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
}


@end
