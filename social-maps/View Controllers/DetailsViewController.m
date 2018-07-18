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
@property (strong, nonatomic) GMSPlace* place;
@property (strong, nonatomic) GMSMapView* mapView;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI {
    self.placeNameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    
    // update the map
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:self.place.coordinate.latitude longitude:self.place.coordinate.longitude zoom:15];
    self.mapView = [GMSMapView mapWithFrame:self.placeView.bounds camera:camera];
    [self.placeView addSubview:self.mapView];
    self.mapView.delegate = self;
    
    // add a marker in the place
    GMSMarker* marker = [GMSMarker markerWithPosition:self.place.coordinate];
    marker.title = self.place.name;
    marker.map = self.mapView;
}
- (IBAction)didTapBack:(id)sender {
}

- (void)setPlace:(GMSPlace*)place {
    _place = place;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
