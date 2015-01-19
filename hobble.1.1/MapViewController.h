//
//  MapViewController.h
//  hobble.1.1
//
//  Created by Steven on 1/18/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *location_manager;

@property (weak, nonatomic) IBOutlet MKMapView *map;

@end
