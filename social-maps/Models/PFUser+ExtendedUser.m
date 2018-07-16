//
//  PFUser+ExtendedUser.m
//  social-maps
//
//  Created by Britney Phan on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "PFUser+ExtendedUser.h"

@implementation PFUser (ExtendedUser)
@dynamic favorites, wishlist;

- (void)addFavorite:(GMSPlace*)place {
    Place* newPlace = [[Place alloc] initWithGMSPlace:place];
    [self addUniqueObject:newPlace forKey:@"favorites"];
    
    // save it to the db
    [self saveInBackground];
}

- (void)removeFavorite:(GMSPlace*)place {
    Place* placeToRemove = [[Place alloc] initWithGMSPlace:place];
    [self removeObject:placeToRemove forKey:@"favorites"];
    
    // save it to the db
    [self saveInBackground];
}

- (void)addToWishlist:(GMSPlace*)place {
    Place* newPlace = [[Place alloc] initWithGMSPlace:place];
    [self addUniqueObject:newPlace forKey:@"wishlist"];
    
    // save it to the db
    [self saveInBackground];
}

- (void)removeFromWishlist:(GMSPlace*)place {
    Place* placeToRemove = [[Place alloc] initWithGMSPlace:place];
    [self removeObject:placeToRemove forKey:@"wishlist"];
    
    // save it to the db
    [self saveInBackground];
}
@end
