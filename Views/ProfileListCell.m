//
//  ProfileListCell.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "ProfileListCell.h"
#import "APIManager.h"

@interface ProfileListCell ()
// Outlet Definitions //
@property (weak, nonatomic) IBOutlet UIImageView *pictureImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

// Instance Properties //
@property (strong, nonatomic) GMSPlace* place;

@end

@implementation ProfileListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)loadFirstImage:(NSArray<GMSPlacePhotoMetadata *> *)photoMetadata {
    
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

- (void)updateUI {
    self.placeImage.layer.cornerRadius = 10;
    self.placeImage.clipsToBounds = YES;
    self.nameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    
    [[APIManager shared] getPhotoMetadata:self.place.placeID :^(NSArray<GMSPlacePhotoMetadata *> *photoMetadata) {
        
        [self loadFirstImage:photoMetadata];
    }];
}

- (void)setPlace:(GMSPlace*)place {
    _place = place;
    [self updateUI];
}

- (GMSPlace*)getPlace {
    return _place;
}
@end
