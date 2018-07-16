//
//  PFUser+ExtendedUser.h
//  social-maps
//
//  Created by Britney Phan on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

@import GooglePlaces
#import "PFUser.h"
#import "Place.h"
#import "APIManager.h"

@interface PFUser (ExtendedUser)
// Instance Properties //
@property NSArray<Place*>* favorites;
@property NSArray<Place*>* wishlist;

// Instance Methods //
- (void)addFavorite:(GMSPlace*)place;
- (void)addToWishlist:(GMSPlace*)place;
@end

