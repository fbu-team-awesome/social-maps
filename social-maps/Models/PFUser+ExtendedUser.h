//
//  PFUser+ExtendedUser.h
//  social-maps
//
//  Created by Britney Phan on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

@import GooglePlaces;

#import "PFUser.h"
#import "Place.h"
#import "APIManager.h"

@interface PFUser (ExtendedUser)
// Instance Properties //
@property NSString* displayName;
@property NSString* hometown;
@property NSString* bio;
@property PFFile* profilePicture;
@property NSArray<Place*>* favorites;
@property NSArray<Place*>* wishlist;

// Instance Methods //
- (void)addFavorite:(GMSPlace*)place;
- (void)removeFavorite:(GMSPlace*)place;
- (void)addToWishlist:(GMSPlace*)place;
- (void)removeFromWishlist:(GMSPlace*)place;
- (void)retrieveFavoritesWithCompletion:(void(^)(NSArray<GMSPlace*>*))completion;
- (void)retrieveWishlistWithCompletion:(void(^)(NSArray<GMSPlace*>*))completion;

@end
