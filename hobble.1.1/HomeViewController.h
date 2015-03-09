/// HomeViewController.h specifies the methods required to control the map view controller.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HomeViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

// The map view the users sees when they come in the app.
@property (weak, nonatomic) IBOutlet MKMapView *map;

// The location manager
@property (strong, nonatomic) CLLocationManager *location_manager;

@end
