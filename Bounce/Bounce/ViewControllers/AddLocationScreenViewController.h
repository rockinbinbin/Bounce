//
//  AddLocationScreenViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/31/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ParseManager.h"

@interface AddLocationScreenViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate, ParseManagerDelegate>


@property (strong, nonatomic) CLLocationManager *location_manager;
@property (nonatomic, strong) PFGeoPoint * groupLocation;
@property (strong, nonatomic) NSString* groupName;
@property __block NSArray *groupUsers;

@property (weak, nonatomic) IBOutlet MKMapView *map;

@end
