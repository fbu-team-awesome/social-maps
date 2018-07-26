//
//  MapMarkerWindow.h
//  social-maps
//
//  Created by Britney Phan on 7/26/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>

@protocol MarkerWindowDelegate;

@interface MapMarkerWindow : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *listsLabel;
@property (strong, nonatomic) GMSPlace *place;
@property (strong, nonatomic) id<MarkerWindowDelegate> delegate;

@end

@protocol MarkerWindowDelegate

- (void) didTapInfo:(GMSPlace *)place;

@end
