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
#import <Parse/Parse.h>
#import "utilities.h"
#import "MessageScreenViewController.h"
#import "RequestsViewController.h"
#import "AppConstant.h"
#import "GroupsListViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "RequestManger.h"
#import "bounce-Swift.h"
#import "UIView+AutoLayout.h"
#import "UIViewController+AMSlideMenu.h"

@interface HomeScreenViewController : UIViewController <CLLocationManagerDelegate, RequestManagerDelegate, UIGestureRecognizerDelegate>

@end
