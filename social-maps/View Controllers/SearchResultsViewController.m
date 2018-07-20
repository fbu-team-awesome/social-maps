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


@interface SearchResultsViewController () <CLLocationManagerDelegate, ResultsViewDelegate, GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *resultsView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) ResultsTableViewController <UISearchResultsUpdating>* resultsViewController;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableDictionary<NSString*, GMSPlace*>* markers;

@end

@implementation SearchResultsViewController {
    
}

- (void)viewDidLoad {
    self.definesPresentationContext = true;
    
    //add notification listener for adding to favorites
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addToFavorites:)
                                                 name:@"AddFavoriteNotification"
                                               object:nil];
    // add notification listener for adding to wishlist
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addToWishlist:)
                                                 name:@"AddToWishlistNotification"
                                               object:nil];
    
    
    
    [self initMap];
    [self initSearch];
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
    self.mapView = [GMSMapView mapWithFrame:self.resultsView.bounds camera:camera];
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMyLocationEnabled:YES];
    
    [self.resultsView addSubview:self.mapView];
    self.mapView.delegate = self;
    
    self.markers = [NSMutableDictionary new];
    [self retrieveUserPlaces];
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

- (void)addMarkers {
    
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
    Place *place = (Place *) notification.object;
    [[APIManager shared] GMSPlaceFromPlace:place withCompletion:^(GMSPlace *place) {
        
        //add to user favorites
        [[PFUser currentUser] addFavorite:place];
        
        //place pin
        [self addFavoritePin:place];
        NSLog(@"Added %@",place.name);
        
        //close search
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void) addToWishlist:(NSNotification *) notification {
    Place *place = (Place *) notification.object;
    [[APIManager shared] GMSPlaceFromPlace:place withCompletion:^(GMSPlace *place) {
        
        //add to user wishlist
        [[PFUser currentUser] addToWishlist:place];
        
        //place pin
        [self addWishlistPin:place];
        NSLog(@"Added %@",place.name);
        
        //close search
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}


- (void)addFavoritePin:(GMSPlace *)place {
    GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
    marker.title = place.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    //marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
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

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    GMSPlace* place = self.markers[marker.title];
    [self performSegueWithIdentifier:@"toDetailsView" sender:place];
}

@end
