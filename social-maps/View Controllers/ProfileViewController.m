//
//  ProfileViewController.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/17/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

@import GoogleMaps;
@import GooglePlaces;

#import "ProfileViewController.h"
#import "DetailsViewController.h"
#import <Parse/Parse.h>
#import "PFUser+ExtendedUser.h"

@interface ProfileViewController () <CLLocationManagerDelegate, GMSMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *profileView;

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocation* currentLocation;
@property (strong, nonatomic) GMSMapView* mapView;
@property (strong, nonatomic) NSArray<GMSPlace*>* favorites;
@property (strong, nonatomic) NSArray<GMSPlace*>* wishlist;
@property (strong, nonatomic) NSMutableDictionary<NSString*, GMSPlace*>* markers;



// TEMPORARY
@property (weak, nonatomic) IBOutlet UITextField *favoriteID;
@property (weak, nonatomic) IBOutlet UITextField *wishlistID;
// ENDTEMPORARY

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // init our location
    self.locationManager = [CLLocationManager new];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.distanceFilter = 50;
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    
    // create map
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:6];
    self.mapView = [GMSMapView mapWithFrame:self.profileView.bounds camera:camera];
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMyLocationEnabled:YES];
    [self.profileView addSubview:self.mapView];
    self.mapView.delegate = self;
    
    // get favs and wishlist
    self.markers = [NSMutableDictionary new];
    [self retrieveUserPlaces];
}

- (void)retrieveUserPlaces {
    PFUser* user = [PFUser currentUser];
    
    // clear map first
    [self.mapView clear];
    
    // retrieve favorites
    [user retrieveFavoritesWithCompletion:
          ^(NSArray<GMSPlace*>* places)
          {
              self.favorites = places;
              [self addFavoritesPins];
          }
     ];
    
    // retrieve wishlist
    [user retrieveWishlistWithCompletion:
          ^(NSArray<GMSPlace*>* places)
          {
              self.wishlist = places;
              [self addWishlistPins];
          }
     ];
}

- (void)addFavoritesPins {
    for(GMSPlace* place in self.favorites)
    {
        GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
        marker.title = place.name;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = self.mapView;
        
        // add the key to our dictionary
        self.markers[marker.title] = place;
    }
}

- (void)addWishlistPins {
    for(GMSPlace* place in self.wishlist)
    {
        GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
        marker.title = place.name;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        marker.map = self.mapView;
        
        // add the key to our dictionary
        self.markers[marker.title] = place;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray<CLLocation*>*)locations {
    CLLocation* location = [locations lastObject];
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:15];
    self.mapView.camera = camera;
    [self.mapView animateToCameraPosition:camera];
}

- (BOOL)mapView:(GMSMapView*)mapView didTapMarker:(GMSMarker*)marker {
    GMSPlace* place = self.markers[marker.title];
    [self performSegueWithIdentifier:@"detailsSegue" sender:place];
    return YES;
}

- (IBAction)favClicked:(id)sender {
    PFUser* user = [PFUser currentUser];
    [[APIManager shared] GMSPlaceFromID:self.favoriteID.text
                         withCompletion:^(GMSPlace *place)
                         {
                             [user addFavorite:place];
                         }
     ];
    
    [self retrieveUserPlaces];
}

- (IBAction)wishlistClicked:(id)sender {
    PFUser* user = [PFUser currentUser];
    [[APIManager shared] GMSPlaceFromID:self.wishlistID.text
                         withCompletion:^(GMSPlace *place)
                         {
                             [user addToWishlist:place];
                         }
     ];
    
    [self retrieveUserPlaces];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"detailsSegue"])
    {
        UINavigationController* navController = (UINavigationController*)[segue destinationViewController];
        DetailsViewController* vc = (DetailsViewController*)navController.topViewController;
        GMSPlace* place = (GMSPlace*)sender;
        [vc setPlace:place];
    }
}

@end
