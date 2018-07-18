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

@interface SearchResultsViewController () <CLLocationManagerDelegate, ResultsViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *resultsView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) ResultsTableViewController <UISearchResultsUpdating>* resultsViewController;
@property (strong, nonatomic) UISearchController *searchController;
@end

@implementation SearchResultsViewController {
    
}

- (void)viewDidLoad {
    self.definesPresentationContext = true;
    
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
    
    
    /*
    _resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    _resultsViewController.delegate = self;
    
    _searchController = [[UISearchController alloc]
                         initWithSearchResultsController:_resultsViewController];
    _searchController.searchResultsUpdater = _resultsViewController;
    
    // Adds search bar to top of view
    [_searchController.searchBar sizeToFit];
    self.navigationItem.titleView = _searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    _searchController.hidesNavigationBarDuringPresentation = NO;
     */
}

- (void)addMarkers {
    
    
    
    
}

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray<CLLocation*>*)locations {
    
    CLLocation* location = [locations lastObject];
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:15];
    self.mapView.camera = camera;
    [self.mapView animateToCameraPosition:camera];
}
/*
// Handle the user's selection.
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
*/
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

@end
