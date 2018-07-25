//
//  DetailsViewController.m
//  social-maps
//
//  Created by Britney Phan on 7/17/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController () <GMSMapViewDelegate>
// Outlet Definitions //
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *placeView;


// Instance Properties //
@property (strong, nonatomic) GMSPlace *place;
@property (strong, nonatomic) Place *parsePlace;
@property (strong, nonatomic) GMSMapView *mapView;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //create Parse Place from GMSPlace
    [Place checkGMSPlaceExists:self.place result:^(Place * _Nonnull newPlace) {
        self.parsePlace = newPlace;
    }];
    
    [self updateContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateContent {
    self.placeNameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    
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

- (IBAction)didTapFavorite:(id)sender {
    [PFUser.currentUser addFavorite:_place];
}

- (IBAction)didTapWishlist:(id)sender {
    [PFUser.currentUser addToWishlist:_place];
}
- (IBAction)didTapCheckIn:(id)sender {
    [self.parsePlace didCheckIn:PFUser.currentUser];
}
@end
