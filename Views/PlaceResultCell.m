//
//  PlaceResultCell.m
//  social-maps
//
//  Created by Britney Phan on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "PlaceResultCell.h"
#import "Place.h"
#import "APIManager.h"

@implementation PlaceResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)configureCell {
    self.nameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    [[APIManager shared] getPhotoMetadata:self.place.placeID :^(NSArray<GMSPlacePhotoMetadata *> *photoMetadata) {
        
        [self loadFirstImage:photoMetadata];
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
         } else {
             self.placeImage.image = photo;
         }
     }];
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
