//
//  DetailsViewController.m
//  social-maps
//
//  Created by Britney Phan on 7/17/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "DetailsViewController.h"
#import "NCHelper.h"

@interface DetailsViewController () <GMSMapViewDelegate>
// Outlet Definitions //
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *placeView;
@property (weak, nonatomic) IBOutlet UILabel *checkInLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *wishlistButton;
@property (weak, nonatomic) IBOutlet UILabel *usersLabel;

// Instance Properties //
@property (strong, nonatomic) GMSPlace *place;
@property (strong, nonatomic) Place *parsePlace;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) NSArray <PFUser *>* usersCheckedIn;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // create Parse Place from GMSPlace
    [Place checkGMSPlaceExists:self.place result:^(Place * _Nonnull newPlace) {
        self.parsePlace = newPlace;
        
        // change buttons if it's favorited/wishlisted
        [self.favoriteButton setSelected:[[PFUser currentUser].favorites containsObject:self.parsePlace]];
        [self.wishlistButton setSelected:[[PFUser currentUser].wishlist containsObject:self.parsePlace]];
        
        [self updateContent];
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    // make sure the navigation bar is always visible
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateContent {
    self.placeNameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    [self updateCheckInLabel];
    [self initUsersLabel];
    
    // update the map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.place.coordinate.latitude longitude:self.place.coordinate.longitude zoom:15];
    self.mapView = [GMSMapView mapWithFrame:self.placeView.bounds camera:camera];
    [self.placeView addSubview:self.mapView];
    self.mapView.delegate = self;
    
    // add a marker in the place
    GMSMarker *marker = [GMSMarker markerWithPosition:self.place.coordinate];
    marker.title = self.place.name;
    marker.map = self.mapView;
}

- (void)setPlace:(GMSPlace*)place {
    _place = place;
}

- (void)initUsersLabel {
    [self.parsePlace getUsersCheckedInWithCompletion:^(NSArray<PFUser *> * _Nullable users) {
        //make a copy of the checked in users
        NSMutableArray *mutableUsers = [[NSMutableArray alloc] init];
        PFUser *myUser = PFUser.currentUser;
        for (PFUser *user in users) {
            //don't copy current user
            if (![user.username isEqualToString:myUser.username]) {
                [mutableUsers addObject:user];
            }
        }
        //store array without current user
        self.usersCheckedIn = [mutableUsers copy];
        
        long usersCount = self.usersCheckedIn.count - 2;
        
        //display names of the first 2 users
        if (self.usersCheckedIn.count == 0) {
            self.usersLabel.text = @"None of your friends have checked in here.";
        } else if (self.usersCheckedIn.count == 1) {
            self.usersLabel.text = [NSString stringWithFormat:@"%@ has checked in here.",self.usersCheckedIn[0].username];
        } else if (self.usersCheckedIn.count == 2) {
            self.usersLabel.text = [NSString stringWithFormat:@"%@ and %@ have checked in here.",self.usersCheckedIn[0].username, self.usersCheckedIn[1].username];
        } else {
            self.usersLabel.text = [NSString stringWithFormat:@"%@, %@, and %ld have checked in here.", self.usersCheckedIn[0].username, self.usersCheckedIn[1].username, usersCount];
        }
                                
    }];
    
}

- (IBAction)didTapFavorite:(id)sender {
    // send it to parse
    if(self.favoriteButton.selected)
    {
        [[PFUser currentUser] removeFavorite:_place];
        
        // send notification
        [NCHelper notify:NTRemoveFavorite object:_place];
    }
    else
    {
        [[PFUser currentUser] addFavorite:_place];
        
        // send notification
        [NCHelper notify:NTAddFavorite object:_place];
    }
    
    // animate
    [UIView animateWithDuration:0.1 animations:^{
        self.favoriteButton.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.favoriteButton.transform = CGAffineTransformIdentity;
        }];
    }];
    
    // haptic feedback
    [[UIImpactFeedbackGenerator new] impactOccurred];
    
    // set the state
    [self.favoriteButton setSelected:!self.favoriteButton.selected];
}

- (IBAction)didTapWishlist:(id)sender {
    // send it to parse
    if(self.wishlistButton.selected)
    {
        [[PFUser currentUser] removeFromWishlist:_place];
        
        // send notification
        [NCHelper notify:NTRemoveFromWishlist object:_place];
    }
    else
    {
        [[PFUser currentUser] addToWishlist:_place];
        
        // send notification
        [NCHelper notify:NTAddToWishlist object:_place];
    }
    
    // animate
    [UIView animateWithDuration:0.1 animations:^{
        self.wishlistButton.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.wishlistButton.transform = CGAffineTransformIdentity;
        }];
    }];
    
    // haptic feedback
    [[UIImpactFeedbackGenerator new] impactOccurred];
    
    // set the state
    [self.wishlistButton setSelected:!self.wishlistButton.selected];
}

- (IBAction)didTapCheckIn:(id)sender {
    [self.parsePlace didCheckIn:PFUser.currentUser];
    [PFUser.currentUser addCheckIn:self.place.placeID withCompletion:^{
        [self updateCheckInLabel];
    }];
}

- (void)updateCheckInLabel {
    [PFUser.currentUser retrieveCheckInCountForPlaceID:self.place.placeID withCompletion:^(NSNumber *count) {
        self.checkInLabel.text = [NSString stringWithFormat: @"%@ check-ins",[count stringValue]];
    }];
}
@end
