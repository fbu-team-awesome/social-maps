//
//  PlaceResultCell.m
//  social-maps
//
//  Created by Britney Phan on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "PlaceResultCell.h"
#import "APIManager.h"
#import "PFUser+ExtendedUser.h"
#import "NCHelper.h"

@implementation PlaceResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.placeImage.layer.cornerRadius = 10;
    self.placeImage.clipsToBounds = YES;
}

- (void)configureCell {
    self.nameLabel.text = nil;
    self.addressLabel.text = nil;
    self.nameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    
    [Place checkPlaceWithIDExists:self.place.placeID result:^(Place * _Nonnull parsePlace) {

        [self.favoriteButton setSelected:[[PFUser currentUser].favorites containsObject:parsePlace]];
        [self.wishlistButton setSelected:[[PFUser currentUser].wishlist containsObject:parsePlace]];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didTapFavorite:(id)sender {
    // if we have no place yet, do not do anything
    if(self.place == nil)
    {
        return;
    }
    
    // check if it is favorited or not
    if(self.favoriteButton.selected)
    {
        [[PFUser currentUser] removeFavorite:self.place];
        [NCHelper notify:NTRemoveFavorite object:self.place];
    }
    else
    {
        [[PFUser currentUser] addFavorite:self.place];
        [NCHelper notify:NTAddFavorite object:self.place];
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
    // if we have no place yet, dont do anything
    if(self.place == nil)
    {
        return;
    }
    
    // check if it is in the wishlist or not
    if(self.wishlistButton.selected)
    {
        [[PFUser currentUser] removeFromWishlist:self.place];
        [NCHelper notify:NTRemoveFromWishlist object:self.place];
    }
    else
    {
        [[PFUser currentUser] addToWishlist:self.place];
        [NCHelper notify:NTAddToWishlist object:self.place];
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
@end
