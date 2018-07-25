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
#import "ParseImageHelper.h"
#import "ProfileListCell.h"
#import "RelationshipsViewController.h"
#import "Relationships.h"
#import "NCHelper.h"

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
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressIndicator;

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
    else
    {
        if([[PFUser currentUser].relationships.following containsObject:self.user.objectId])
        {
            [self.followButton setTitle:@"-" forState:UIControlStateNormal];
        }
    }
    
    // create map
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:37.7749 longitude:-122.4194 zoom:6];
    self.mapView = [GMSMapView mapWithFrame:self.profileMapView.bounds camera:camera];
    [self.profileMapView addSubview:self.mapView];
    self.mapView.delegate = self;
    
    // if it's us, we'll show stuff differently
    if([[PFUser currentUser].objectId isEqualToString:self.user.objectId])
    {
        // init our location
        self.locationManager = [CLLocationManager new];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager requestAlwaysAuthorization];
        self.locationManager.distanceFilter = 50;
        [self.locationManager startUpdatingLocation];
        self.locationManager.delegate = self;
        
        // set up map for our location
        self.mapView.settings.myLocationButton = YES;
        [self.mapView setMyLocationEnabled:YES];
        
        // hide follow button
        self.followButton.hidden = YES;
    }
    
    // init tableview
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setRowHeight:90];
    
    // get favs and wishlist
    self.markers = [NSMutableDictionary new];
    [self retrieveUserPlaces];
    
    // update UI with user info
    self.displayNameLabel.text = self.user.displayName;
    self.handleLabel.text = [NSString stringWithFormat:@"@%@", self.user.username];
    self.hometownLabel.text = self.user.hometown;
    self.bioLabel.text = self.user.bio;
    [ParseImageHelper setImageFromPFFile:self.user.profilePicture forImageView:self.profilePicture];
    
    // pre-load get followers and following (we need to do this anyway for the follower/following count)
    [self.user retrieveRelationshipWithCompletion:^(Relationships* relationship) {
        self.user.relationships = relationship;
        // update UI with counts
        [self.followersLabel setText:[NSString stringWithFormat:@"%lu followers", relationship.followers.count]];
        [self.followingLabel setText:[NSString stringWithFormat:@"%lu following", relationship.following.count]];
    }];

    // add NC observers
    [self addNotificationObservers];
    
    // set UI styles
    [self initUIStyles];
}

- (void)addNotificationObservers {
    [NCHelper addObserver:self type:NTAddFavorite selector:@selector(addToFavorites:)];
    [NCHelper addObserver:self type:NTAddToWishlist selector:@selector(addToWishlist:)];
    [NCHelper addObserver:self type:NTNewFollow selector:@selector(newFollowing:)];
    [NCHelper addObserver:self type:NTUnfollow selector:@selector(newUnfollow:)];
}

- (void)setUser:(PFUser*)user {
    _user = user;
}

- (void)initUIStyles {
    [self setRoundedCornersToView:self.profilePicture];
    [self setRoundedCornersToView:self.profilePictureView];
    [self addShadowToView:self.profilePictureView withOffset:CGSizeZero];
    [self addShadowToView:self.myPlacesView withOffset:CGSizeMake(0,6)];
    [self setRoundedCornersToView:self.followButton];
    [self addShadowToView:self.followButton withOffset:CGSizeMake(0,0)];
    
    // set switch background when off
    self.placesSwitch.layer.cornerRadius = self.placesSwitch.frame.size.height / 2;
    self.placesSwitch.clipsToBounds = YES;
    self.placesSwitch.backgroundColor = [UIColor colorNamed:@"VTR_Main"];
}

- (void)setRoundedCornersToView:(UIView*)view {
    view.layer.cornerRadius = view.frame.size.width / 2;
    view.clipsToBounds = YES;
}

- (void)addShadowToView:(UIView*)view withOffset:(CGSize)offset {
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
    else if([segue.identifier isEqualToString:@"followersSegue"])
    {
        RelationshipsViewController* vc = (RelationshipsViewController*)[segue destinationViewController];
        [PFUser retrieveUsersWithIDs:self.user.relationships.followers
                withCompletion:^(NSArray<PFUser*>* users)
                {
                    [vc setUsers:users];
                }
         ];
    }
    else if([segue.identifier isEqualToString:@"followingSegue"])
    {
        RelationshipsViewController* vc = (RelationshipsViewController*)[segue destinationViewController];
        [PFUser retrieveUsersWithIDs:self.user.relationships.following
                withCompletion:^(NSArray<PFUser*>* users)
                {
                    [vc setUsers:users];
                }
         ];
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

- (IBAction)followClicked:(id)sender {
    if([self.followButton.titleLabel.text isEqualToString:@"+"])
    {
        [[PFUser currentUser] follow:self.user];
        [self.followButton setTitle:@"-" forState:UIControlStateNormal];
    }
    else
    {
        [[PFUser currentUser] unfollow:self.user];
        [self.followButton setTitle:@"+" forState:UIControlStateNormal];
    }
}

- (void) addToFavorites:(NSNotification *) notification {
    GMSPlace* place = (GMSPlace*)notification.object;
    
    // place pin
    GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
    marker.title = place.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    self.markers[marker.title] = place;
    
    // add to tableview
    NSMutableArray<GMSPlace*>* favorites = (NSMutableArray*)self.favorites;
    [favorites addObject:place];
    self.favorites = (NSArray*)favorites;
    [self.tableView reloadData];
    NSLog(@"Added %@",place.name);
}

- (void) addToWishlist:(NSNotification *) notification {
    GMSPlace* place = (GMSPlace*)notification.object;
    
    // place pin
    GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
    marker.title = place.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    marker.map = self.mapView;
    self.markers[marker.title] = place;
    
    NSLog(@"Added %@",place.name);
}

- (void)newFollowing:(NSNotification*)notification {
    PFUser* user = (PFUser*)notification.object;
    
    // if this is our profile, then we will add the user to our following
    if([[PFUser currentUser].objectId isEqualToString:self.user.objectId])
    {
        NSMutableArray<NSString*>* following = (NSMutableArray*)self.user.relationships.following;
        [following addObject:user.objectId];
        self.user.relationships.following = (NSArray*)following;
        
        // update the following label
        [self.followingLabel setText:[NSString stringWithFormat:@"%lu following", self.user.relationships.following.count]];
    }
    // if this user is the user that was followed, then update their followers
    else if ([self.user.objectId isEqualToString:user.objectId])
    {
        NSMutableArray<NSString*>* followers = (NSMutableArray*)self.user.relationships.followers;
        [followers addObject:[PFUser currentUser].objectId];
        self.user.relationships.followers = (NSArray*)followers;
        
        // update the followers label
        [self.followersLabel setText:[NSString stringWithFormat:@"%lu followers", self.user.relationships.followers.count]];
    }
}

- (void)newUnfollow:(NSNotification*)notification {
    PFUser* user = (PFUser*)notification.object;
    
    // if this is our profile, then we will remove the user from our following
    if([[PFUser currentUser].objectId isEqualToString:self.user.objectId])
    {
        NSMutableArray<NSString*>* following = (NSMutableArray*)self.user.relationships.following;
        [following removeObject:user.objectId];
        self.user.relationships.following = (NSArray*)following;
        
        // update the following label
        [self.followingLabel setText:[NSString stringWithFormat:@"%lu following", self.user.relationships.following.count]];
    }
    // if this user is the user that was unfollowed, then update their followers
    else if ([self.user.objectId isEqualToString:user.objectId])
    {
        NSMutableArray<NSString*>* followers = (NSMutableArray*)self.user.relationships.followers;
        [followers removeObject:[PFUser currentUser].objectId];
        self.user.relationships.followers = (NSArray*)followers;
        
        // update the followers label
        [self.followersLabel setText:[NSString stringWithFormat:@"%lu followers", self.user.relationships.followers.count]];
    }
}
@end
