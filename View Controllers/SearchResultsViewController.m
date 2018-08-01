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
#import "MapMarkerWindow.h"

@interface SearchResultsViewController () <CLLocationManagerDelegate, ResultsViewDelegate, GMSMapViewDelegate, MarkerWindowDelegate>

@property (weak, nonatomic) IBOutlet UIView *resultsView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet MapMarkerWindow *markerWindowView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *markerWindowGestureRecognizer;
@property (strong, nonatomic) ResultsTableViewController <UISearchResultsUpdating>* resultsViewController;
@property (strong, nonatomic) MarkerManager *markerManager;
@property (nonatomic, assign) BOOL userPlacesRetrieved;
@property (nonatomic, assign) BOOL followPlacesRetrieved;
@property (strong, nonatomic) MapMarkerWindow *infoWindow;
@property (strong, nonatomic) GMSMarker *locationMarker;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) ResultsTableViewController <UISearchResultsUpdating>* resultsViewController;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableDictionary<NSString*, GMSPlace*>* markers;

@end

@implementation SearchResultsViewController {
    
}

- (void)viewDidLoad {
    self.definesPresentationContext = true;
    
    [self addNotificationObservers];
    [self initMap];
    [self initSearch];
}

- (void)addNotificationObservers {
    [NCHelper addObserver:self type:NTAddFavorite selector:@selector(addToFavorites:)];
    [NCHelper addObserver:self type:NTRemoveFavorite selector:@selector(updatePins:)];
    [NCHelper addObserver:self type:NTAddToWishlist selector:@selector(addToWishlist:)];
    [NCHelper addObserver:self type:NTRemoveFromWishlist selector:@selector(updatePins:)];
    [NCHelper addObserver:self type:NTNewFollow selector:@selector(addPinsOfNewFollow:)];
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
    CGRect mapFrame = self.view.bounds;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    mapFrame.size.height -= tabBarHeight;
    
    // create map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:6];
    self.mapView = [GMSMapView mapWithFrame:mapFrame camera:camera];
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMyLocationEnabled:YES];
    
    [self.resultsView addSubview:self.mapView];
    self.mapView.delegate = self;
    
    self.markers = [NSMutableDictionary new];
    [self retrieveUserPlaces];
    [self retrievePlacesOfUsersFollowing];
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

- (void)retrievePlacesOfUsersFollowing {
    
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
                        [self addFavoriteOfFollowingPin:place];
                    }
                }];
            }
        }];
    }];
}

- (void)retrieveUserPlaces {
    // clear map first
    [self.mapView clear];
    
    // retrieve favorites
    [PFUser.currentUser retrieveFavoritesWithCompletion:
     ^(NSArray<GMSPlace*>* places)
     {
         //self.favorites = places;
         for (GMSPlace * place in places) {
             [self addFavoritePin:place];
         }
     }
     ];
    
    // retrieve wishlist
    [PFUser.currentUser retrieveWishlistWithCompletion:
     ^(NSArray<GMSPlace*>* places)
     {
         for (GMSPlace *place in places) {
             [self addWishlistPin:place];
         }
     }
     ];
}



- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray<CLLocation*>*)locations {
    
    CLLocation* location = [locations lastObject];
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:15];
    self.mapView.camera = camera;
    [self.mapView animateToCameraPosition:camera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    DetailsViewController *detailsController = (DetailsViewController *)[segue destinationViewController];
    [detailsController setPlace:sender];
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
- (void) addToFavorites:(NSNotification *) notification {
    GMSPlace* place = (GMSPlace*)notification.object;

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

#pragma mark - Add pins to dictionaries and map when notification is receieved

- (void)setNewFavoritePin:(NSNotification *)notification {
    GMSMarker *marker = [self.markerManager setFavoritePin:notification.object];
    marker.map = self.mapView;
    // place pin
    [self addFavoritePin:place];
    NSLog(@"Added %@",place.name);
}

- (void)updatePins:(NSNotification *)notification {
    // remove the places
    [self retrieveUserPlaces];
}

- (void) addToWishlist:(NSNotification *) notification {
    GMSPlace* place = (GMSPlace*)notification.object;
    
    // place pin
    [self addWishlistPin:place];
    NSLog(@"Added %@",place.name);
}

- (void)addPinsOfNewFollow:(NSNotification *) notification {
    
    [notification.object retrieveFavoritesWithCompletion:^(NSArray<GMSPlace *> *places) {
        
        // add each place to map
        for (GMSPlace *place in places) {
            [self addFavoriteOfFollowingPin:place];
        }
    }];
}

#pragma mark - Remove pins from dictionary when notification is receieved

- (void)removeFavoritePin:(NSNotification *)notification {
    NSMutableArray *favoritesArray = [self.markerManager.markersByMarkerType valueForKey:@"favorites"];
    for (NSUInteger i = favoritesArray.count; i > 0; i--) {
        GMSMarker *thisGMSMarker = favoritesArray[i-1];
        Marker *thisMarker = thisGMSMarker.userData;
        GMSPlace *thisPlace = notification.object;
        if ([thisMarker.place.placeID isEqualToString:thisPlace.placeID]) {
            [favoritesArray removeObjectAtIndex:(i-1)];
            thisGMSMarker.map = nil;
        }
    }
- (void)addFavoritePin:(GMSPlace *)place {
    GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
    marker.title = place.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    
    // add the key to our dictionary
    self.markers[marker.title] = place;
}

- (void)addWishlistPin:(GMSPlace *)place {
    GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
    marker.title = place.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    marker.map = self.mapView;
        
        // add the key to our dictionary
    self.markers[marker.title] = place;
}

- (void)addFavoriteOfFollowingPin:(GMSPlace *)place {
    
    GMSMarker *marker = [GMSMarker markerWithPosition:place.coordinate];
    marker.title = place.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    
    self.markers[marker.title] = place;
    
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    GMSPlace* place = self.markers[marker.title];
    [self performSegueWithIdentifier:@"toDetailsView" sender:place];
}

#pragma mark - Marker Windows

- (MapMarkerWindow *) loadNib {
    [[NSBundle mainBundle] loadNibNamed:@"MarkerWindow" owner:self options:nil];
    MapMarkerWindow *markerWindow = self.markerWindowView;
    [markerWindow addGestureRecognizer:self.markerWindowGestureRecognizer];
    return markerWindow;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    //store location so we can move window accordingly when map moves
    self.locationMarker = marker;
    
    //remove info from marker window so we can reuse it
    [self.infoWindow removeFromSuperview];
    
    //instantiate new infoWindow
    self.infoWindow = [self loadNib];
    self.infoWindow.delegate = self;
    
    //pass info to window
    self.infoWindow.marker = (Marker *)marker.userData;
    [self.infoWindow configureWindow];
    self.infoWindow.center = [self.mapView.projection pointForCoordinate:marker.position];
    self.infoWindow.frame = CGRectMake(self.infoWindow.frame.origin.x, self.infoWindow.frame.origin.y - 85, self.infoWindow.frame.size.width, self.infoWindow.frame.size.height);
    [self.resultsView addSubview:self.infoWindow];
    
    return false;
}

- (void)didTapInfo:(GMSPlace *)place {
    [self performSegueWithIdentifier:@"toDetailsView" sender:place];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    if (self.locationMarker != nil) {
        CLLocationCoordinate2D location = self.locationMarker.position;
        self.infoWindow.center = [self.mapView.projection pointForCoordinate:location];
        self.infoWindow.frame = CGRectMake(self.infoWindow.frame.origin.x, self.infoWindow.frame.origin.y - 85, self.infoWindow.frame.size.width, self.infoWindow.frame.size.height);
    } else {
        NSLog(@"location marker is nil");
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.infoWindow removeFromSuperview];
}

@end
