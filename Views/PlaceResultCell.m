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
}

-(void)configureCell {
    self.nameLabel.text = nil;
    self.addressLabel.text = nil;
    self.placeImage.image = nil;
    self.nameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    
    [[APIManager shared] getPhotoMetadata:self.place.placeID :^(NSArray<GMSPlacePhotoMetadata *> *photoMetadata) {
        
        [self loadFirstImage:photoMetadata];
    }];
    
    [Place checkPlaceWithIDExists:self.place.placeID result:^(Place * _Nonnull parsePlace) {

        [self.favoriteButton setSelected:[[PFUser currentUser].favorites containsObject:parsePlace]];
        [self.wishlistButton setSelected:[[PFUser currentUser].wishlist containsObject:parsePlace]];
    }];
}

-(void)loadFirstImage:(NSArray<GMSPlacePhotoMetadata *> *)photoMetadata {
    
    GMSPlacePhotoMetadata *firstPhoto = photoMetadata.firstObject;
    
    [[GMSPlacesClient sharedClient]
     loadPlacePhoto:firstPhoto
     constrainedToSize:self.placeImage.bounds.size
     scale:self.placeImage.window.screen.scale
     callback:^(UIImage *_Nullable photo, NSError *_Nullable error) {
         if (error) {
             NSLog(@"Error: %@", [error description]);
         }
         else {
             self.placeImage.image = photo;
         }
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
