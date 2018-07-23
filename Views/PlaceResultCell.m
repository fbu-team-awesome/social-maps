//
//  PlaceResultCell.m
//  social-maps
//
//  Created by Britney Phan on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "PlaceResultCell.h"
#import "Place.h"

@implementation PlaceResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)configureCell {
    self.nameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didTapFavorite:(id)sender {
    [Place checkPlaceWithIDExists:self.place.placeID result:^(Place * result) {
        [result addFavoriteNotification];
    }];
}

- (IBAction)didTapWishlist:(id)sender {
    [Place checkPlaceWithIDExists:self.place.placeID result:^(Place * result) {
        [result addToWishlistNotification];
    }];
}

@end
