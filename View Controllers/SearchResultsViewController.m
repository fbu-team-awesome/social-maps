//
//  SearchResultsViewController.m
//  social-maps
//
//  Created by Bevin Benson on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "DetailsViewController.h"
#import "SearchCell.h"
#import "ResultsTableViewController.h"
#import "NCHelper.h"
#import "MarkerManager.h"

@interface SearchResultsViewController () <CLLocationManagerDelegate, ResultsViewDelegate, GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *resultsView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) ResultsTableViewController <UISearchResultsUpdating>* resultsViewController;
@property (strong, nonatomic) MarkerManager *markerManager;


@end

@implementation SearchResultsViewController

- (void)viewDidLoad {
    self.definesPresentationContext = true;
    
    self.markerManager = [MarkerManager new];
    
    [self addNotificationObservers];
    [self initMap];
    [self initSearch];
}

- (void)addNotificationObservers {
    [NCHelper addObserver:self type:NTAddFavorite selector:@selector(setNewFavoritePin:)];
    // [NCHelper addObserver:self type:NTRemoveFavorite selector:@selector(updatePins:)];
    [NCHelper addObserver:self type:NTAddToWishlist selector:@selector(setNewWishlistPin:)];
    // [NCHelper addObserver:self type:NTRemoveFromWishlist selector:@selector(updatePins:)];
    [NCHelper addObserver:self type:NTNewFollow selector:@selector(setNewFollowPins:)];
}

- (void)initMap {
    
    // init our location
    self.locationManager = [CLLocationManager new];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.distanceFilter = 50;
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    
    // create map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:6];
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMyLocationEnabled:YES];
    
    [self.resultsView addSubview:self.mapView];
    self.mapView.delegate = self;
    
    // initialize marker dictionaries
    [self.markerManager initMarkerDictionaries];
    [self.markerManager initDefaultFilters];
    
    // get the places and show on map based on filters
    [self retrieveUserPlacesWithCompletion:^{
        [self addPinsToMap];
    }];
    [self retrievePlacesOfUsersFollowingWithCompletion:^{
        [self addPinsToMap];
    }];
}

- (void)initSearch {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ResultsView" bundle:[NSBundle mainBundle]];
    
    _resultsViewController = [storyboard instantiateViewControllerWithIdentifier:@"ResultsTable"];
    _resultsViewController.delegate = self;
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_resultsViewController];
    _searchController.searchResultsUpdater = _resultsViewController;
    
    //add search bar
    [_searchController.searchBar sizeToFit];
    self.navigationItem.titleView = _searchController.searchBar;
    
    _searchController.hidesNavigationBarDuringPresentation = NO;
}

- (void)retrievePlacesOfUsersFollowingWithCompletion:(void(^)(void))completion {
    // get the Relationships of the current user
    [PFUser.currentUser retrieveRelationshipWithCompletion:^(Relationships *relationships) {
        // get array of users that current user is following
        [Relationships retrieveFollowingWithId:relationships.objectId WithCompletion:^(NSArray *following) {
            for (NSString *userId in following) {
                // get the user that has id userId
                PFUser *user = [PFUser retrieveUserWithId:userId];
                
                // get the favorites of each user
                [user retrieveFavoritesWithCompletion:^(NSArray<GMSPlace *> *places) {
                    // add each place to map
                    for (GMSPlace *place in places) {
                        [self.markerManager setFavoriteOfFollowingPin:place :user];
                    }
                    completion();
                }];
            }
        }];
    }];
}

- (void)retrieveUserPlacesWithCompletion:(void(^)(void))completion {
    // clear map first
    [self.mapView clear];
    
    // retrieve favorites
    [PFUser.currentUser retrieveFavoritesWithCompletion:
     ^(NSArray<GMSPlace*>* places)
     {
         for (GMSPlace * place in places) {
             [self.markerManager setFavoritePin:place];
         }
         completion();
     }];
    
    // retrieve wishlist
    [PFUser.currentUser retrieveWishlistWithCompletion:
     ^(NSArray<GMSPlace*>* places)
     {
         for (GMSPlace *place in places) {
             [self.markerManager setWishlistPin:place];
         }
         completion();
     }];
}

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray<CLLocation*>*)locations {
    CLLocation* location = [locations lastObject];
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:15];
    self.mapView.camera = camera;
    [self.mapView animateToCameraPosition:camera];
}

- (void)didSelectPlace:(GMSPlace *)place {
    NSArray *whitelistedTypes = @[@"locality", @"cities", @"sublocality", @"country", @"continent"];
    BOOL isRegion = NO;
    
    for (NSString *type in place.types) {
        if ([whitelistedTypes containsObject:type]) {
            isRegion = YES;
        }
    }
    if (isRegion) {
        NSLog(@"Is a location");
        GMSCameraPosition *newPosition = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude zoom:6];
        [self.mapView setCamera:newPosition];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self performSegueWithIdentifier:@"toDetailsView" sender: place];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    GMSPlace* place = marker.userData;
    [self performSegueWithIdentifier:@"toDetailsView" sender:place];
}

- (void)addPinsToMap {
    [self.mapView clear];
    NSMutableArray<GMSMarker *> *currentPins = [NSMutableArray new];
    for (NSString *key in self.markerManager.filters) {
        if ([[self.markerManager.filters valueForKey:key] boolValue]) {
            [currentPins addObjectsFromArray:[self.markerManager.markersByPlaceType valueForKey:key]];
            [currentPins addObjectsFromArray:[self.markerManager.markersByMarkerType valueForKey:key]];
        }
    }
    for (GMSMarker *marker in currentPins) {
        marker.map = self.mapView;
    }
}

#pragma - Add pins to dictionaries and map when notification is receieved
- (void)setNewFavoritePin:(NSNotification *)notification {
    GMSMarker *marker = [self.markerManager setFavoritePin:notification.object];
    marker.map = self.mapView;
}

- (void)setNewWishlistPin:(NSNotification *)notification {
    GMSMarker *marker = [self.markerManager setWishlistPin:notification.object];
    marker.map = self.mapView;
}

- (void)setNewFollowPins:(NSNotification *)notification {
    [notification.object retrieveFavoritesWithCompletion:^(NSArray<GMSPlace *> *places) {
        // add each place to map
        for (GMSPlace *place in places) {
            GMSMarker *marker = [self.markerManager setFavoriteOfFollowingPin:place :notification.object];
            marker.map = self.mapView;
        }
    }];
}

- (void) addToFavorites:(NSNotification *) notification {
    GMSPlace* place = (GMSPlace*)notification.object;
    [self.markerManager setFavoritePin:place];
    NSLog(@"Added %@",place.name);
}

- (void) addToWishlist:(NSNotification *) notification {
    GMSPlace* place = (GMSPlace*)notification.object;
    [self.markerManager setWishlistPin:place];
    NSLog(@"Added %@",place.name);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    DetailsViewController *detailsController = (DetailsViewController *)[segue destinationViewController];
    [detailsController setPlace:sender];
}
@end
