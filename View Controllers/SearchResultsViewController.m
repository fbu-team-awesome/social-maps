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
#import "Marker.h"
#import "FilterListViewController.h"

@interface SearchResultsViewController () <CLLocationManagerDelegate, ResultsViewDelegate, GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *resultsView;
@property (strong, nonatomic) UIView *filterView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UIButton *filterButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) ResultsTableViewController <UISearchResultsUpdating>* resultsViewController;
@property (nonatomic, assign) BOOL userPlacesRetrieved;
@property (nonatomic, assign) BOOL followPlacesRetrieved;

@end

@implementation SearchResultsViewController

- (void)viewDidLoad {
    self.definesPresentationContext = true;
    
    [self addNotificationObservers];
    [self initSearch];
    [self initFilter];
    [self initMap];
}

- (void)addNotificationObservers {
    [NCHelper addObserver:self type:NTAddFavorite selector:@selector(setNewFavoritePin:)];
    [NCHelper addObserver:self type:NTRemoveFavorite selector:@selector(removeFavoritePin:)];
    [NCHelper addObserver:self type:NTAddToWishlist selector:@selector(setNewWishlistPin:)];
    [NCHelper addObserver:self type:NTRemoveFromWishlist selector:@selector(removeWishlistPin:)];
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
    
    // create the map frame
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat filterViewHeight = self.filterView.frame.size.height;
    CGFloat searchBarHeight = self.navigationItem.titleView.frame.size.height;
    CGRect mapFrame = CGRectMake(self.filterView.frame.origin.x, self.filterView.frame.origin.y + self.filterView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - filterViewHeight - tabBarHeight - searchBarHeight);

    // create map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:6];
    self.mapView = [GMSMapView mapWithFrame:mapFrame camera:camera];
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMyLocationEnabled:YES];
    
    [self.resultsView addSubview:self.mapView];
    self.mapView.delegate = self;
    
    // initialize marker dictionaries
    [[MarkerManager shared] initMarkerDictionaries];
    [[MarkerManager shared] initDefaultFilters];
    
    self.userPlacesRetrieved = NO;
    self.followPlacesRetrieved = NO;
    
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

- (void)addPinsIfFinished {
    if (self.userPlacesRetrieved && self.followPlacesRetrieved) {
        [self addPinsToMap];
    }
}

- (void)initFilter {
    self.filterView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationItem.titleView.bounds.origin.y + self.navigationItem.titleView.bounds.size.height, self.view.bounds.size.width, 75)];
    [self.filterView setBackgroundColor:[UIColor whiteColor]];
    [self.resultsView addSubview:self.filterView];
    
    self.filterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.filterButton addTarget:self action:@selector(addFilterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.filterButton setUserInteractionEnabled:YES];
    self.filterButton.center = CGPointMake(self.filterView.frame.size.width/2, self.filterView.frame.size.height/2);
    [self.filterButton setTitle:@"Filter" forState:UIControlStateNormal];
    [self.filterButton sizeToFit];
    [self.filterView addSubview:self.filterButton];
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
                        
                        [[MarkerManager shared] setFavoriteOfFollowingPin:place :user];
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
             [[MarkerManager shared] setFavoritePin:place];
         }
         completion();
     }];
    
    // retrieve wishlist
    [PFUser.currentUser retrieveWishlistWithCompletion:
     ^(NSArray<GMSPlace*>* places)
     {
         for (GMSPlace *place in places) {
             [[MarkerManager shared]setWishlistPin:place];
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
    MarkerManager *markerManager = [MarkerManager shared];
    for (NSString *key in markerManager.filters) {
        if ([[markerManager.filters valueForKey:key] boolValue]) {
            [currentPins addObjectsFromArray:[markerManager.markersByPlaceCategory valueForKey:key]];
            [currentPins addObjectsFromArray:[markerManager.markersByMarkerType valueForKey:key]];
        }
    }
    for (GMSMarker *marker in currentPins) {
        marker.map = self.mapView;
    }
}

#pragma - Add pins to dictionaries and map when notification is receieved

- (void)setNewFavoritePin:(NSNotification *)notification {
    GMSMarker *marker = [[MarkerManager shared] setFavoritePin:notification.object];
    marker.map = self.mapView;
}

- (void)setNewWishlistPin:(NSNotification *)notification {
    GMSMarker *marker = [[MarkerManager shared] setWishlistPin:notification.object];
    marker.map = self.mapView;
}

- (void)setNewFollowPins:(NSNotification *)notification {
    [notification.object retrieveFavoritesWithCompletion:^(NSArray<GMSPlace *> *places) {
        // add each place to map
        for (GMSPlace *place in places) {
            GMSMarker *marker = [[MarkerManager shared] setFavoriteOfFollowingPin:place :notification.object];
            marker.map = self.mapView;
        }
    }];
}


#pragma - Remove pins from dictionary when notification is receieved

- (void)removeFavoritePin:(NSNotification *)notification {
    MarkerManager *markerManager = [MarkerManager shared];
    NSMutableArray *favoritesArray = [markerManager.markersByMarkerType valueForKey:@"favorites"];
    for (NSUInteger i = favoritesArray.count; i > 0; i--) {
        GMSMarker *thisGMSMarker = favoritesArray[i-1];
        Marker *thisMarker = thisGMSMarker.userData;
        GMSPlace *thisPlace = notification.object;
        if ([thisMarker.place.placeID isEqualToString:thisPlace.placeID]) {
            [favoritesArray removeObjectAtIndex:(i-1)];
            thisGMSMarker.map = nil;
        }
    }
}

- (void)removeWishlistPin:(NSNotification *)notification {
    MarkerManager *markerManager = [MarkerManager shared];
    NSMutableArray *wishlistArray = [markerManager.markersByMarkerType valueForKey:@"wishlist"];
    for (NSUInteger i = wishlistArray.count; i > 0; i--) {
        GMSMarker *thisGMSMarker = wishlistArray[i-1];
        Marker *thisMarker = thisGMSMarker.userData;
        GMSPlace *thisPlace = notification.object;
        if ([thisMarker.place.placeID isEqualToString:thisPlace.placeID]) {
            [wishlistArray removeObjectAtIndex:(i-1)];
            thisGMSMarker.map = nil;
        }
    }
}

- (void)addFilterButtonTapped {
    NSLog(@"tapped");
    UIStoryboard *filterStoryboard = [UIStoryboard storyboardWithName:@"FilterList" bundle:nil];
    FilterListViewController *filter = [filterStoryboard instantiateViewControllerWithIdentifier:@"filter"];
    
    [self presentViewController:filter animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    DetailsViewController *detailsController = (DetailsViewController *)[segue destinationViewController];
    [detailsController setPlace:sender];
}
@end
