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
#import "AppDelegate.h"
#import "Helper.h"
#import "ProfileListCell.h"

@interface ProfileViewController () <CLLocationManagerDelegate, GMSMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
// Outlet Definitions //
@property (weak, nonatomic) IBOutlet UIView *profileMapView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) IBOutlet UILabel *hometownLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIView *profilePictureView;
@property (weak, nonatomic) IBOutlet UIView *myPlacesView;
@property (weak, nonatomic) IBOutlet UIView *tableviewView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISwitch *placesSwitch;
@property (weak, nonatomic) IBOutlet UILabel *switchLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;

// Instance Properties //
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocation* currentLocation;
@property (strong, nonatomic) GMSMapView* mapView;
@property (strong, nonatomic) NSArray<GMSPlace*>* favorites;
@property (strong, nonatomic) NSArray<GMSPlace*>* wishlist;
@property (strong, nonatomic) NSMutableDictionary<NSString*, GMSPlace*>* markers;
@property (strong, nonatomic) PFUser* user;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // if we have no user, then it is the current user
    if(self.user == nil)
    {
        self.user = [PFUser currentUser];
    }
    
    // init tableview
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setRowHeight:90];
    
    // init our location
    self.locationManager = [CLLocationManager new];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.distanceFilter = 50;
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    
    // create map
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:6];
    self.mapView = [GMSMapView mapWithFrame:self.profileMapView.bounds camera:camera];
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMyLocationEnabled:YES];
    [self.profileMapView addSubview:self.mapView];
    self.mapView.delegate = self;
    
    // get favs and wishlist
    self.markers = [NSMutableDictionary new];
    [self retrieveUserPlaces];
    
    // update UI with user info
    self.displayNameLabel.text = self.user.displayName;
    self.handleLabel.text = [NSString stringWithFormat:@"@%@", self.user.username];
    self.hometownLabel.text = self.user.hometown;
    self.bioLabel.text = self.user.bio;
    [Helper setImageFromPFFile:self.user.profilePicture forImageView:self.profilePicture];
    
    // set cool UI
    [self makeUILookGood];
}

- (void)setUser:(PFUser*)user {
    _user = user;
}

- (void)makeUILookGood {
    [self makeRoundCorners:self.profilePicture];
    [self makeRoundCorners:self.profilePictureView];
    [self addShadow:self.profilePictureView withOffset:CGSizeZero];
    self.followersButton.layer.cornerRadius = self.followersButton.frame.size.height / 2;
    self.followersButton.clipsToBounds = YES;
    [self addShadow:self.followersButton withOffset:CGSizeMake(0, 0)];
    self.followingButton.layer.cornerRadius = self.followingButton.frame.size.height / 2;
    self.followingButton.clipsToBounds = YES;
    [self addShadow:self.followingButton withOffset:CGSizeMake(0, 4)];
    [self addShadow:self.myPlacesView withOffset:CGSizeMake(0,6)];
    
    // set switch background when off
    self.placesSwitch.layer.cornerRadius = self.placesSwitch.frame.size.height / 2;
    self.placesSwitch.clipsToBounds = YES;
    self.placesSwitch.backgroundColor = [UIColor colorWithRed:227/255.0 green:130/255.0 blue:94/255.0 alpha:255];
}

- (void)makeRoundCorners:(UIView*)view {
    view.layer.cornerRadius = view.frame.size.width / 2;
    view.clipsToBounds = YES;
}

- (void)addShadow:(UIView*)view withOffset:(CGSize)offset {
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = offset;
    view.layer.shadowRadius = 5;
    view.layer.shadowOpacity = 0.2;
    view.layer.masksToBounds = NO;
}

- (void)retrieveUserPlaces {
    // clear map first
    [self.mapView clear];
    
    // retrieve favorites
    [self.user retrieveFavoritesWithCompletion:
          ^(NSArray<GMSPlace*>* places)
          {
              self.favorites = places;
              [self.tableView reloadData];
              [self addFavoritesPins];
          }
     ];
    
    // retrieve wishlist
    [self.user retrieveWishlistWithCompletion:
          ^(NSArray<GMSPlace*>* places)
          {
              self.wishlist = places;
              [self.tableView reloadData];
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

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    GMSPlace* place = self.markers[marker.title];
    [self performSegueWithIdentifier:@"detailsSegue" sender:place];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"detailsSegue"])
    {
        DetailsViewController* vc = (DetailsViewController *)[segue destinationViewController];
        GMSPlace* place = (GMSPlace*)sender;
        [vc setPlace:place];
    }
    else if([segue.identifier isEqualToString:@"listDetailsSegue"])
    {
        DetailsViewController* vc = (DetailsViewController *)[segue destinationViewController];
        ProfileListCell* cell = (ProfileListCell*)sender;
        [vc setPlace:[cell getPlace]];
    }
}

- (IBAction)logoutClicked:(id)sender {
    // logout
    [PFUser logOutInBackground];
    
    // go back to login screen
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    delegate.window.rootViewController = viewController;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ProfileListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileListCell" forIndexPath:indexPath];
    GMSPlace* place = self.favorites[indexPath.row];
    
    if(place != nil)
    {
        [cell setPlace:place];
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favorites.count;
}

- (IBAction)switchClicked:(id)sender {
    if(self.placesSwitch.on)
    {
        self.mapView.hidden = NO;
        self.tableviewView.hidden = YES;
        self.switchLabel.text = @"Map";
    }
    else
    {
        self.mapView.hidden = YES;
        self.tableviewView.hidden = NO;
        self.switchLabel.text = @"List";
    }
}

@end
