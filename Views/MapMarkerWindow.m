//
//  MapMarkerWindow.m
//  social-maps
//
//  Created by Britney Phan on 7/26/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "MapMarkerWindow.h"
#import "UIStylesHelper.h"

@implementation MapMarkerWindow

- (void)awakeFromNib {
    [super awakeFromNib];

    // style the picture
    self.placePicture.layer.cornerRadius = 8;
    self.placePicture.clipsToBounds = YES;
}

- (IBAction)didTapView:(id)sender {
   [self.delegate didTapInfo:self.marker.place];
}

- (void)configureWindow {
    // load photo
    [[APIManager shared] getPhotoMetadata:self.marker.place.placeID :^(NSArray<GMSPlacePhotoMetadata *> *photoMetadata) {
        [[GMSPlacesClient sharedClient] loadPlacePhoto:photoMetadata.firstObject callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
            self.placePicture.image = photo;
            [UIView animateWithDuration:0.4 animations:^{
                self.placePicture.alpha = 1;
            }];
        }];
    }];
    
    self.nameLabel.text = self.marker.place.name;
    self.addressLabel.text = self.marker.place.formattedAddress;
    switch(self.marker.type) {
        case favorites: {
            self.listsLabel.text = @"Added to your favorites.";
            break;
        }
        case wishlist: {
            self.listsLabel.text = @"Added to your wishlist.";
            break;
        }
        case followFavorites: {
            self.listsLabel.text = [NSString stringWithFormat:@"Added to %@'s favorites.", self.marker.markerOwner.displayName];
            break;
        }
        case other: {
            self.listsLabel.text = @"";
            break;
        }
    }
}

@end
