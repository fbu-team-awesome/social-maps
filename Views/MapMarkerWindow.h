//
//  MapMarkerWindow.h
//  social-maps
//
//  Created by Britney Phan on 7/26/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>
#import "Marker.h"

@protocol MarkerWindowDelegate;

@interface MapMarkerWindow : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *listsLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet MapMarkerWindow *markerWindowView;
@property (strong, nonatomic) Marker *marker;
@property (strong, nonatomic) id<MarkerWindowDelegate> delegate;

+ (UIView *) instanceFromNib;
- (void) configureWindow;

@end

@protocol MarkerWindowDelegate

- (void) didTapInfo:(GMSPlace *)place;

@end
