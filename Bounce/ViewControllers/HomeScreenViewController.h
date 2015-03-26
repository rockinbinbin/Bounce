//
//  HomeScreenViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface HomeScreenViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *location_manager;

@property (weak, nonatomic) IBOutlet MKMapView *map;
- (IBAction)messageButtonClicked:(id)sender;

@end
