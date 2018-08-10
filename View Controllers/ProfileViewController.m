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
#import "ListViewController.h"
#import "UIStylesHelper.h"
#import "Marker.h"

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
@property (strong, nonatomic) UIImageView *settingsImage;

// Instance Properties //
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocation* currentLocation;
@property (strong, nonatomic) GMSMapView* mapView;
@property (strong, nonatomic) NSArray<GMSPlace*>* favorites;
@property (strong, nonatomic) NSArray<GMSPlace*>* wishlist;
@property (strong, nonatomic) NSMutableDictionary<NSString*, GMSPlace*>* markers;
@property (strong, nonatomic) PFUser* user;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSDictionary<NSString *, UIImage *> *placeImages;
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
            [self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        }
    }
    
    // create map
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:37.7749 longitude:-122.4194 zoom:6];
    
    //profile map view initially reflects the size of the phone displayed on the storyboard, must manually set mapview width while profile map view is still the wrong size
    CGRect bounds = self.profileMapView.bounds;
    bounds.size.width = self.view.bounds.size.width;
    self.profileMapView.bounds = bounds;
    
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
        
        // show list button instead
        [self.followButton setTitle:@"View Lists" forState:UIControlStateNormal];
        
        // show settings wheel (which will serve for logout)
        UIImageView *settingsImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 21, 21)];
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutClicked)];
        [settingsImage setImage:[UIImage imageNamed:@"settings"]];
        settingsImage.userInteractionEnabled = YES;
        [settingsImage addGestureRecognizer:gestureRecognizer];
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsImage];
        self.navigationController.navigationBar.topItem.rightBarButtonItem = rightBarButtonItem;
    }
    
    // init tableview
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setRowHeight:90];
    
    // get favs and wishlist
    [self.progressIndicator startAnimating];
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
    
    // set up refresh control
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(retrieveUserPlaces) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // set navbar title
    if([self.user.username isEqualToString:[PFUser currentUser].username])
    {
        [self.navigationController.navigationBar.topItem setTitle:@"MY PROFILE"];
    }
    else
    {
        [self.navigationController.navigationBar.topItem setTitle:self.user.username];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // set navbar styles
    [UIStylesHelper setCustomNavBarStyle:self.navigationController];
    [UIStylesHelper addShadowToView:self.navigationController.navigationBar withOffset:CGSizeMake(0, 2) withRadius:1.5 withOpacity:0.1];
    
    // show navbar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // deselect cells
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if(indexPath != nil)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)addNotificationObservers {
    [NCHelper addObserver:self type:NTAddFavorite selector:@selector(addToFavorites:)];
    [NCHelper addObserver:self type:NTRemoveFavorite selector:@selector(removeFromFavorites:)];
    [NCHelper addObserver:self type:NTAddToWishlist selector:@selector(addToWishlist:)];
    [NCHelper addObserver:self type:NTRemoveFromWishlist selector:@selector(removeFromWishlist:)];
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
    [self addShadowToView:self.myPlacesView withOffset:CGSizeMake(0, 4)];
    self.followButton.layer.cornerRadius = self.followButton.frame.size.height / 2;
    self.followButton.clipsToBounds = YES;
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

- (void)fetchPlaceImagesFromPlaces:(NSArray<GMSPlace *> *)places withCompletion:(void(^)(void))completion {
    NSMutableDictionary<NSString *, UIImage *> *mutableDict = [NSMutableDictionary dictionaryWithDictionary:self.placeImages];
    __block NSUInteger placeCount = 0;
    
    for(GMSPlace *place in places)
    {
        [[APIManager shared] getPhotoMetadata:place.placeID :^(NSArray<GMSPlacePhotoMetadata *> *photoMetadata) {
            [[GMSPlacesClient sharedClient] loadPlacePhoto:photoMetadata.firstObject callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
                mutableDict[place.placeID] = photo;
                placeCount++;
                
                if(placeCount == places.count)
                {
                    self.placeImages = [mutableDict copy];
                    if(completion != nil)
                    {
                        completion();
                    }
                }
            }];
        }];
    }
}

- (void)retrieveUserPlaces {
    // clear map first
    [self.mapView clear];
    
    // retrieve favorites
    [self.user retrieveFavoritesWithCompletion:
          ^(NSArray<GMSPlace*>* places)
          {
              self.favorites = places;
              [self addFavoritesPins];
              [self fetchPlaceImagesFromPlaces:places withCompletion:^{
                  [self.tableView reloadData];
                  [self.progressIndicator stopAnimating];
                  [self.refreshControl endRefreshing];
                  
                  // retrieve wishlist
                  [self.user retrieveWishlistWithCompletion:
                   ^(NSArray<GMSPlace*>* places)
                   {
                       self.wishlist = places;
                       [self addWishlistPins];
                       [self fetchPlaceImagesFromPlaces:places withCompletion:nil];
                   }
                   ];
              }];
          }
     ];
}

- (void)addFavoritesPins {
    for(GMSPlace* place in self.favorites)
    {
        GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
        marker.title = place.name;
        marker.appearAnimation = kGMSMarkerAnimationPop;
        [Marker setMarkerImageWithGMSMarker:marker];
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
        [Marker setMarkerImageWithGMSMarker:marker];
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
        [vc setUser:self.user withRelationshipType:RTFollower];
    }
    else if([segue.identifier isEqualToString:@"followingSegue"])
    {
        RelationshipsViewController* vc = (RelationshipsViewController*)[segue destinationViewController];
        [vc setUser:self.user withRelationshipType:RTFollowing];
    }
}

- (void)logoutClicked {
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
        cell.pictureImage.image = self.placeImages[place.placeID];
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
    //if we are on our own profile, show lists instead
    if([[PFUser currentUser].objectId isEqualToString:self.user.objectId]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ListView" bundle:[NSBundle mainBundle]];
        ListViewController *listVC = (ListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"List"];
        listVC.placeImages = self.placeImages;
        [self.navigationController pushViewController:listVC animated:YES];
    }
    else if([self.followButton.titleLabel.text isEqualToString:@"Follow"])
    {
        [[PFUser currentUser] follow:self.user];
        [self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
    }
    else
    {
        [[PFUser currentUser] unfollow:self.user];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
}

- (void) addToFavorites:(NSNotification *) notification {
    GMSPlace* place = (GMSPlace*)notification.object;
    
    // place pin
    GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
    Marker *thisMarker = [[Marker alloc] initWithGMSPlace:place markerType:favorites user:[PFUser currentUser]];
    marker.userData = thisMarker;
    marker.title = place.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    [Marker setMarkerImageWithGMSMarker:marker];
    marker.map = self.mapView;
    self.markers[marker.title] = place;
    
    // add to tableview
    self.favorites = [[NSArray arrayWithObject:place] arrayByAddingObjectsFromArray:self.favorites];
    [self.tableView reloadData];
    NSLog(@"Added %@",place.name);
}

- (void)removeFromFavorites:(NSNotification *)notification {
    GMSPlace *place = (GMSPlace *)notification.object;
    
    // remove the places
    NSMutableArray<GMSPlace *> *favorites = [self.favorites mutableCopy];
    [favorites removeObject:place];
    self.favorites = [favorites copy];
    
    // re-add the pins
    [self.mapView clear];
    [self addFavoritesPins];
    
    // refresh tableview
    [self.tableView reloadData];
    
}

- (void) addToWishlist:(NSNotification *) notification {
    GMSPlace* place = (GMSPlace*)notification.object;
    
    // place pin
    GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
    Marker *thisMarker = [[Marker alloc] initWithGMSPlace:place markerType:wishlist user:[PFUser currentUser]];
    marker.userData = thisMarker;
    marker.title = place.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    [Marker setMarkerImageWithGMSMarker:marker];
    marker.map = self.mapView;
    self.markers[marker.title] = place;
    
    NSLog(@"Added %@",place.name);
}

- (void)removeFromWishlist:(NSNotification *)notification {
    GMSPlace *place = (GMSPlace *)notification.object;
    
    // remove the place
    NSMutableArray<GMSPlace *> *wishlist = [self.wishlist mutableCopy];
    [wishlist removeObject:place];
    self.wishlist = [wishlist copy];
    
    // re-add the pins
    [self.mapView clear];
    [self addWishlistPins];
}

- (void)newFollowing:(NSNotification*)notification {
    PFUser* user = (PFUser*)notification.object;
    
    // if this is our profile, then we will add the user to our following
    if([[PFUser currentUser].objectId isEqualToString:self.user.objectId])
    {
        self.user.relationships.following = [[NSArray arrayWithObject:user.objectId] arrayByAddingObjectsFromArray:self.user.relationships.following];
        
        // update the following label
        [self.followingLabel setText:[NSString stringWithFormat:@"%lu following", self.user.relationships.following.count]];
    }
    // if this user is the user that was followed, then update their followers
    else if ([self.user.objectId isEqualToString:user.objectId])
    {
        self.user.relationships.followers = [[NSArray arrayWithObject:[PFUser currentUser].objectId] arrayByAddingObjectsFromArray:self.user.relationships.followers];
        
        // update the followers label
        [self.followersLabel setText:[NSString stringWithFormat:@"%lu followers", self.user.relationships.followers.count]];
    }
}

- (void)newUnfollow:(NSNotification*)notification {
    PFUser* user = (PFUser*)notification.object;
    
    // if this is our profile, then we will remove the user from our following
    if([[PFUser currentUser].objectId isEqualToString:self.user.objectId])
    {
        NSMutableArray<NSString*>* following = [NSMutableArray arrayWithArray:self.user.relationships.following];
        [following removeObject:user.objectId];
        self.user.relationships.following = [NSArray arrayWithArray:following];
        
        // update the following label
        [self.followingLabel setText:[NSString stringWithFormat:@"%lu following", self.user.relationships.following.count]];
    }
    // if this user is the user that was unfollowed, then update their followers
    else if ([self.user.objectId isEqualToString:user.objectId])
    {
        NSMutableArray<NSString*>* followers = [NSMutableArray arrayWithArray:self.user.relationships.followers];
        [followers removeObject:[PFUser currentUser].objectId];
        self.user.relationships.followers = [NSArray arrayWithArray:followers];
        
        // update the followers label
        [self.followersLabel setText:[NSString stringWithFormat:@"%lu followers", self.user.relationships.followers.count]];
    }
}
@end
