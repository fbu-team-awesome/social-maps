//
//  SearchCell.m
//  social-maps
//
//  Created by Britney Phan on 7/18/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "SearchCell.h"
#import "PFUser+ExtendedUser.h"
#import "NCHelper.h"

@interface SearchCell ()
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;


@property (strong, nonatomic) Place *parsePlace;
@property (strong, nonatomic) GMSPlace *place;
@end

@implementation SearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void) configureCell {
    if (_prediction) {
        _nameLabel.text =  _prediction.attributedPrimaryText.string;
        _addressLabel.text = _prediction.attributedSecondaryText.string;
        
        [Place checkPlaceWithIDExists:_prediction.placeID
                               result:^(Place * _Nonnull result)
         {
             self.parsePlace = result;
             
             // get Google place
             [[APIManager shared] GMSPlaceFromPlace:self.parsePlace
                                     withCompletion:^(GMSPlace *place)
              {
                  self.place = place;
              }];
             
             // update button states
             [self.favoriteButton setSelected:[[PFUser currentUser].favorites containsObject:self.parsePlace]];
         }];
    } else {
        NSLog(@"No place found for cell");
    }
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
    [Place checkPlaceWithIDExists:_prediction.placeID result:^(Place * result) {
        [[APIManager shared] GMSPlaceFromPlace:result
                             withCompletion:^(GMSPlace *place)
                             {
                                 [[PFUser currentUser] addToWishlist:place];
                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"AddToWishlistNotification" object:place];
                             }
         ];
    }];
}
@end
