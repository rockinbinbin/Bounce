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
#import "RequestManger.h"

@interface HomeScreenViewController : UIViewController <CLLocationManagerDelegate, RequestManagerDelegate>

@property (strong, nonatomic) CLLocationManager *location_manager;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;
@property (weak, nonatomic) IBOutlet UIButton *repliesButton;
@property (weak, nonatomic) IBOutlet UIButton *endRequestButton;
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UIView *repliesView;
@property (weak, nonatomic) IBOutlet UIView *iconView;
@property (strong, nonatomic) IBOutlet UILabel *numOfMessagesLabel;
@property (weak, nonatomic) IBOutlet UIButton *getHomeButton;
@property (strong, nonatomic) UIView* roundedView;
- (IBAction)endRequestButtonClicked:(id)sender;
- (IBAction)repliesButtonClicked:(id)sender;
- (IBAction)messageButtonClicked:(id)sender;
- (IBAction)privateChatButtonClicked:(id)sender;
- (IBAction)groupsChatButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton;

@end
