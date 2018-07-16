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
}

- (void)addToWishlist:(GMSPlace*)place {
    
}
@end
