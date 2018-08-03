//
//  MapMarkerWindow.m
//  social-maps
//
//  Created by Britney Phan on 7/26/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "MapMarkerWindow.h"

@implementation MapMarkerWindow 

- (IBAction)didTapView:(id)sender {
   [self.delegate didTapInfo:self.marker.place];
}

- (void)configureWindow {
    self.nameLabel.text = self.marker.place.name;
    self.addressLabel.text = self.marker.place.formattedAddress;
    switch(self.marker.type) {
        case favorites: {
            self.listsLabel.text = @"Added to your favorites.";
        }
        case wishlist: {
            self.listsLabel.text = @"Added to your wishlist.";
        }
        case followFavorites: {
            self.listsLabel.text = [NSString stringWithFormat:@"Added to %@'s favorites.", self.marker.markerOwner.displayName];
        }
    }
}

@end
