//
//  MainMapViewController.m
//  social-maps
//
//  Created by Bevin Benson on 8/7/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MainMapViewController.h"
#import "FilterListViewController.h"
#import "DetailsViewController.h"
#import "SearchCell.h"
#import "MarkerManager.h"
#import "FilterPillHelper.h"
#import "MapMarkerWindow.h"
#import "NCHelper.h"
#import "SSFadingScrollView.h"
#import "PillCancelButton.h"
#import "FilterPillView.h"
#import "SearchBarView.h"
#import "SearchBarTextField.h"

@interface MainMapViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteFetcherDelegate, MarkerWindowDelegate, FilterDelegate, UIScrollViewDelegate, SearchBarViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *resultsView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *markerWindowGestureRecognizer;
@property (strong, nonatomic) IBOutlet MapMarkerWindow *markerWindowView;
@property (strong, nonatomic) SearchBarView *searchView;
@property (strong, nonatomic) UIView *filterView;
@property (strong, nonatomic) UIButton *filterButton;
@property (strong, nonatomic) SSFadingScrollView *pillScrollView;
@property (strong, nonatomic) UINavigationController *filterListNavController;
@property (strong, nonatomic) GMSAutocompleteFetcher *fetcher;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) GMSMarker *locationMarker;
@property (strong, nonatomic) MapMarkerWindow *infoWindow;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSArray<GMSAutocompletePrediction *> *predictions;
@property (strong, nonatomic) NSArray <FilterPillView *> *pillViews;
@property (strong, nonatomic) GMSMarker *tempMarker;

@end

@implementation MainMapViewController

- (void)viewDidLoad {
    [self addNotificationObservers];
    [self initSearch];
    [self initTableView];
    [self initMarkers];
    [self initMap];
    [self initFilterView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)addNotificationObservers {
    [NCHelper addObserver:self type:NTAddFavorite selector:@selector(setNewFavoritePin:)];
    [NCHelper addObserver:self type:NTRemoveFavorite selector:@selector(removeFavoritePin:)];
    [NCHelper addObserver:self type:NTAddToWishlist selector:@selector(setNewWishlistPin:)];
    [NCHelper addObserver:self type:NTRemoveFromWishlist selector:@selector(removeWishlistPin:)];
    [NCHelper addObserver:self type:NTNewFollow selector:@selector(setNewFollowPins:)];
}

- (void)initTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat searchViewHeight = self.searchView.frame.origin.y + self.searchView.frame.size.height;
    [self.tableView setFrame:CGRectMake(0, self.searchView.frame.origin.y + self.searchView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - tabBarHeight - searchViewHeight)];
    
    [self.tableView setHidden:YES];
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
    CGFloat searchViewHeight = self.searchView.frame.origin.y + self.searchView.frame.size.height;
    CGRect mapFrame = CGRectMake(0, self.searchView.frame.origin.y + self.searchView.frame.size.height + self.filterView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - filterViewHeight - tabBarHeight - searchViewHeight);
    [self.mapView setClipsToBounds:NO];
    
    // create map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:6];
    self.mapView = [GMSMapView mapWithFrame:mapFrame camera:camera];
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMyLocationEnabled:YES];
    
    [self.resultsView addSubview:self.mapView];
    self.mapView.delegate = self;
}

- (void)initMarkers {
    // initialize marker dictionaries
    [[MarkerManager shared] initMarkerDictionaries];
    [[MarkerManager shared] initDefaultFilters];
    
    // get the places and show on map based on filters
    [self retrieveUserPlacesWithCompletion:^{
        [self addPinsToMap];
    }];
    [self retrievePlacesOfUsersFollowingWithCompletion:^{
        [self addPinsToMap];
    }];
}

- (void)initSearch {
    self.searchView = [[SearchBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 90)];
    self.fetcher = [[GMSAutocompleteFetcher alloc] init];
    self.fetcher.delegate = self;
    [self.resultsView addSubview:self.searchView];
}

- (void)cancelClicked:(id)sender {
    [self.mapView setHidden:NO];
    [self.filterView setHidden:NO];
    [self.tableView setHidden:YES];
    
    self.tempMarker.map = nil;
    self.tempMarker = nil;
    [self.view endEditing:YES];
}

- (void)textChanged:(id)sender {
    SearchBarTextField *textField = sender;
    NSString *searchText = textField.text;
    if (searchText.length == 0) {
        [self.mapView setHidden:NO];
        [self.filterView setHidden:NO];
        [self.tableView setHidden:YES];
        self.predictions = [NSArray new];
        
        self.tempMarker.map = nil;
        self.tempMarker = nil;
        [self.view endEditing:YES];
    }
    else if (searchText.length == 1) {
        [self.tableView setHidden:NO];
        [self.mapView setHidden:YES];
        [self.filterView setHidden:YES];
        
        self.searchView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.searchView.layer.shadowOffset = CGSizeMake(0, 1);
        self.searchView.layer.shadowRadius = 1;
        self.searchView.layer.shadowOpacity = 0.15;
        
        [self.fetcher sourceTextHasChanged:searchText];
        [self.tableView reloadData];
    }
    else {
        [self.fetcher sourceTextHasChanged:searchText];
        [self.tableView reloadData];
    }
}

- (void)initFilterView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FilterList" bundle:nil];
    self.filterListNavController = [storyboard instantiateViewControllerWithIdentifier:@"filterNav"];
    FilterListViewController *filterListVC = (FilterListViewController *)self.filterListNavController.topViewController;
    filterListVC.delegate = self;
    
    self.filterView = [[UIView alloc] initWithFrame:CGRectMake(0, self.searchView.frame.origin.y + self.searchView.frame.size.height - 10, self.view.bounds.size.width, 50)];
    [self.filterView setBackgroundColor:[UIColor colorNamed:@"VTR_Background"]];
    
    self.filterView.layer.masksToBounds = NO;
    self.filterView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.filterView.layer.shadowOffset = CGSizeMake(0, 2);
    self.filterView.layer.shadowRadius = 1;
    self.filterView.layer.shadowOpacity = 0.25;
    self.filterView.layer.borderColor = [UIColor clearColor].CGColor;
    [self.resultsView addSubview:self.filterView];
    
    self.pillScrollView = [[SSFadingScrollView alloc] initWithFadeSize:30 axis:SSScrollViewFadeAxisHorizontal];
    [self.pillScrollView setFadeTrailingEdge:NO];
    self.pillScrollView.delegate = self;
    [self.pillScrollView setScrollEnabled:YES];
    [self.pillScrollView setShowsHorizontalScrollIndicator:NO];
    
    self.pillViews = [[NSArray alloc] init];
    NSMutableDictionary *filters = [MarkerManager shared].allFilters;
    NSArray *lists = [MarkerManager shared].filterKeys;
    CGRect lastFrame = CGRectMake(0, 0, 0, 0);
    for (NSString *list in lists) {
        if ([[filters objectForKey:list] boolValue]) {
            FilterType type;
            if ([list isEqualToString:kFavoritesKey]) {
                type = favFilter;
            }
            else if ([list isEqualToString:kWishlistKey]) {
                type = wishFilter;
            }
            else if ([list isEqualToString:kFollowFavKey]) {
                type = friendFilter;
            }
            else {
                type = placeFilter;
            }
            FilterPillView *pillView = [[FilterPillHelper shared] createFilterPill:type withName:list];
            [pillView setFrame:CGRectMake(lastFrame.origin.x + CGRectGetWidth(lastFrame) + 5, 3, pillView.frame.size.width, pillView.frame.size.height)];
            lastFrame = pillView.frame;
            [self.pillScrollView addSubview:pillView];
            
            NSMutableArray *mutablePillViews = [self.pillViews mutableCopy];
            [mutablePillViews addObject:pillView];
            self.pillViews = [NSArray arrayWithArray:mutablePillViews];
        }
    }
    
    self.filterButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 15, 0, 20, 20)];
    [self.filterButton setCenter:CGPointMake(self.filterButton.center.x, CGRectGetHeight(lastFrame)/2 + 3)];
    [self.filterButton setImage:[UIImage imageNamed:@"filter_control"] forState:UIControlStateNormal];
    [self.filterButton addTarget:self action:@selector(addFilterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.filterButton setUserInteractionEnabled:YES];
    [self.filterButton sizeToFit];
    [self.filterView addSubview:self.filterButton];
    
    [self.pillScrollView setFrame:CGRectMake(self.filterButton.frame.origin.x + CGRectGetWidth(self.filterButton.frame) + 5, 0, CGRectGetWidth(self.filterView.frame), self.filterView.frame.size.height)];
    CGFloat contentWidth = lastFrame.origin.x + CGRectGetWidth(lastFrame) + CGRectGetMinX(self.pillScrollView.frame) + 5;
    [self.pillScrollView setCenter:CGPointMake(self.pillScrollView.center.x, self.filterView.frame.size.height/2)];
    [self.pillScrollView setContentSize:CGSizeMake(contentWidth, CGRectGetHeight(self.pillScrollView.frame))];
    [self.filterView addSubview:self.pillScrollView];
}

- (void)pillCancelTapped:(id)sender {
    PillCancelButton *button = (PillCancelButton *)sender;
    FilterPillView *thisPill = nil;
    for (FilterPillView *pill in self.pillViews) {
        if ([pill.viewId isEqualToString:button.buttonId]) {
            thisPill = pill;
        }
    }
    
    switch(thisPill.filterType) {
        case favFilter: {
            [[MarkerManager shared].typeFilters setObject:[NSNumber numberWithBool:NO] forKey:kFavoritesKey];
            [[MarkerManager shared].allFilters setObject:[NSNumber numberWithBool:NO] forKey:kFavoritesKey];
            break;
        }
        case wishFilter: {
            [[MarkerManager shared].typeFilters setObject:[NSNumber numberWithBool:NO] forKey:kWishlistKey];
            [[MarkerManager shared].allFilters setObject:[NSNumber numberWithBool:NO] forKey:kWishlistKey];
            break;
        }
        case friendFilter: {
            [[MarkerManager shared].typeFilters setObject:[NSNumber numberWithBool:NO] forKey:kFollowFavKey];
            [[MarkerManager shared].allFilters setObject:[NSNumber numberWithBool:NO] forKey:kFollowFavKey];
            break;
        }
        case placeFilter: {
            [[MarkerManager shared].placeFilters setObject:[NSNumber numberWithBool:NO] forKey:thisPill.filterName];
            [[MarkerManager shared].allFilters setObject:[NSNumber numberWithBool:NO] forKey:thisPill.filterName];
            break;
        }
    }
    
    NSMutableArray *mutablePillViews = [self.pillViews mutableCopy];
    [mutablePillViews removeObject:thisPill];
    self.pillViews = [[NSArray alloc] initWithArray:mutablePillViews];
    [thisPill removeFromSuperview];
    [self updateScrollView:thisPill];
    [self addPinsToMap];
}

- (void)updateScrollView:(FilterPillView *)removedPillView {
    int count = 0;
    CGFloat newX = removedPillView.frame.origin.x;
    for (FilterPillView *pill in self.pillViews) {
        if (CGRectGetMinX(pill.frame) > CGRectGetMaxX(removedPillView.frame)) {
            count++;
            [pill setFrame:CGRectMake(newX, pill.frame.origin.y, CGRectGetWidth(pill.frame), CGRectGetHeight(pill.frame))];
            newX = newX + CGRectGetWidth(pill.frame) + 5;
        }
    }
    
    CGFloat contentWidth = self.pillScrollView.contentSize.width;
    [self.pillScrollView setContentSize:CGSizeMake(contentWidth - CGRectGetWidth(removedPillView.frame), self.pillScrollView.contentSize.height)];
    NSLog(@"%d", count);
}

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray<CLLocation*>*)locations {
    CLLocation* location = [locations lastObject];
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:15];
    self.mapView.camera = camera;
    [self.mapView animateToCameraPosition:camera];
}

#pragma mark - Table view

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    if (self.predictions.count > 0) {
        cell.prediction = self.predictions[indexPath.row];
        [cell configureCell];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.predictions.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    self.tempMarker = [GMSMarker markerWithPosition:cell.place.coordinate];
    self.tempMarker.icon = [UIImage imageNamed:@"temp_marker_icon"];
    
    Marker *marker = [[Marker alloc] initWithGMSPlace:cell.place markerType:other user:nil];
    self.tempMarker.userData = marker;
    self.tempMarker.map = self.mapView;
    
    NSSet *townTypes = [NSSet setWithArray:@[@"locality", @"administrative_area_level_2", @"administrative_area_level_3", @"administrative_area_level_4", @"administrative_area_level_5", @"postal_code", @"sublocality_level_4", @"sublocality_level_5", @"sublocality_level_3", @"sublocality_level_2", @"sublocality_level_1"]];
    
    float zoom = 16;
    for (NSString *type in cell.place.types) {
        if ([type isEqualToString:@"country"] | [type isEqualToString:@"administrative_area_level_1"]) {
            zoom = 6;
        }
        else if ([townTypes containsObject:type]) {
            if (zoom > 12) {
                zoom = 12;
            }
        }
        else if ([type isEqualToString:@"neighborhood"]) {
            if (zoom > 13) {
                zoom = 13;
            }
        }
        else {
            if (zoom > 15)
                zoom = 15;
        }
    }
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:cell.place.coordinate.latitude longitude:cell.place.coordinate.longitude zoom:zoom];
    [self.mapView setCamera:camera];
    [self.searchView setHidden:NO];
    [self.mapView setHidden:NO];
    [self.tableView setHidden:YES];
}

#pragma mark - Autocomplete

- (void)didAutocompleteWithPredictions:(nonnull NSArray<GMSAutocompletePrediction *> *)predictions {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (GMSAutocompletePrediction *prediction in predictions) {
        [results addObject:prediction];
    }
    self.predictions = [results copy];
}

- (void)didFailAutocompleteWithError:(nonnull NSError *)error {
    NSLog(@"Error fetching autocomplete results: %@", error.localizedDescription);
}

#pragma mark - Get places

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

#pragma mark - Place pins on the map

- (void)addPinsToMap {
    [self.mapView clear];
    NSMutableArray<GMSMarker *> *currentPins = [NSMutableArray new];
    MarkerManager *markerManager = [MarkerManager shared];
    
    for (NSString *key in markerManager.typeFilters) {
        if ([[markerManager.typeFilters valueForKey:key] boolValue]) {
            NSArray *markersOfType = [markerManager.markersByMarkerType valueForKey:key];
            for (GMSMarker *marker in markersOfType) {
                Marker *thisMarker = marker.userData;
                BOOL allTypesYes = YES;
                for (NSString *type in thisMarker.types) {
                    NSString *currentTypeCategory = [markerManager.detailedTypeDict objectForKey:type];
                    if (currentTypeCategory && !(BOOL)[[markerManager.placeFilters objectForKey:currentTypeCategory] boolValue]) {
                        allTypesYes = NO;
                    }
                }
                if (allTypesYes) {
                    [currentPins addObject:marker];
                }
            }
        }
    }
    for (GMSMarker *marker in currentPins) {
        [Marker setMarkerImageWithGMSMarker:marker];
        marker.map = self.mapView;
    }
}

#pragma mark - Add pins to dictionaries and map when notification is receieved

- (void)setNewFavoritePin:(NSNotification *)notification {
    GMSMarker *marker = [[MarkerManager shared] setFavoritePin:notification.object];
    [Marker setMarkerImageWithGMSMarker:marker];
    marker.map = self.mapView;
}

- (void)setNewWishlistPin:(NSNotification *)notification {
    GMSMarker *marker = [[MarkerManager shared] setWishlistPin:notification.object];
    [Marker setMarkerImageWithGMSMarker:marker];
    marker.map = self.mapView;
}

- (void)setNewFollowPins:(NSNotification *)notification {
    [notification.object retrieveFavoritesWithCompletion:^(NSArray<GMSPlace *> *places) {
        // add each place to map
        for (GMSPlace *place in places) {
            GMSMarker *marker = [[MarkerManager shared] setFavoriteOfFollowingPin:place :notification.object];
            [Marker setMarkerImageWithGMSMarker:marker];
            marker.map = self.mapView;
        }
    }];
}

#pragma mark - Remove pins from dictionary when notification is receieved

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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    DetailsViewController *detailsController = (DetailsViewController *)[segue destinationViewController];
    [detailsController setPlace:sender];
}

- (void)filterSelectionDone {
    [self addPinsToMap];
    [self.filterView removeFromSuperview];
    [self initFilterView];
}

- (void)addFilterButtonTapped {
    [self presentViewController:self.filterListNavController animated:YES completion:nil];
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
    self.infoWindow.userInteractionEnabled = YES;
    
    //pass info to window
    self.infoWindow.marker = (Marker *)marker.userData;
    [self.infoWindow configureWindow];
    self.infoWindow.center = [self.mapView.projection pointForCoordinate:marker.position];
    self.infoWindow.frame = CGRectMake(self.infoWindow.frame.origin.x, self.infoWindow.frame.origin.y, self.infoWindow.frame.size.width, self.infoWindow.frame.size.height);
    [self.resultsView addSubview:self.infoWindow];
    [self.resultsView bringSubviewToFront:self.searchView];
    [self.resultsView bringSubviewToFront:self.filterView];
    
    return false;
}

- (void)didTapInfo:(GMSPlace *)place {
    [self performSegueWithIdentifier:@"toDetailsView" sender:place];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    if (self.locationMarker != nil) {
        CLLocationCoordinate2D location = self.locationMarker.position;
        self.infoWindow.center = [self.mapView.projection pointForCoordinate:location];
        self.infoWindow.frame = CGRectMake(self.infoWindow.frame.origin.x, self.infoWindow.frame.origin.y, self.infoWindow.frame.size.width, self.infoWindow.frame.size.height);
    } else {
        NSLog(@"location marker is nil");
    }
}
@end
