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

- (IBAction)endRequestButtonClicked:(id)sender;
- (IBAction)repliesButtonClicked:(id)sender;
- (IBAction)messageButtonClicked:(id)sender;
- (IBAction)privateChatButtonClicked:(id)sender;
- (IBAction)groupsChatButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *leftMenuButton;

@property (weak, nonatomic) NSString *genderMatching;
@property (nonatomic) float timeAllocated;

@end
