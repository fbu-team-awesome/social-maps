//
//  SearchCell.m
//  social-maps
//
//  Created by Britney Phan on 7/18/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "SearchCell.h"

@implementation SearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void) configureCell {
    if (_prediction) {
        _nameLabel.text =  _prediction.attributedPrimaryText.string;
        _addressLabel.text = _prediction.attributedSecondaryText.string;
    } else {
        NSLog(@"No place found for cell");
    }
}
- (IBAction)didTapFavorite:(id)sender {
    //TODO: add condition for unfavoriting
    [Place checkPlaceWithIDExists:_prediction.placeID result:^(Place * result) {
        [result addFavoriteNotification];
    }];

}
- (IBAction)didTapWishlist:(id)sender {
    [Place checkPlaceWithIDExists:_prediction.placeID result:^(Place * result) {
        [result addToWishlistNotification];
    }];
}
@end
