//
//  PFUser+ExtendedUser.m
//  social-maps
//
//  Created by Britney Phan on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "PFUser+ExtendedUser.h"

@implementation PFUser (ExtendedUser)
@dynamic displayName, hometown, bio, profilePicture, favorites, wishlist;

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

- (void)retrieveFavoritesWithCompletion:(void(^)(NSArray<GMSPlace*>*))completion {
    NSMutableArray<GMSPlace*>* places = [NSMutableArray new];
    for(Place* favorite in self.favorites)
    {
        // we need to query the place first
        PFQuery* query = [PFQuery queryWithClassName:@"Place"];
        [query getObjectInBackgroundWithId:favorite.objectId
               block:^(PFObject* _Nullable result, NSError * _Nullable error)
               {
                   // now we can look it up in Google
                   [[APIManager shared] GMSPlaceFromPlace:(Place*)result
                                        withCompletion:^(GMSPlace* place)
                                        {
                                            [places addObject:place];
                                            
                                            // if we have looked up all of the places, return full array
                                            if(places.count == self.favorites.count)
                                            {
                                                completion((NSArray*)places);
                                            }
                                        }
                    ];
               }
         ];
    }
}

- (void)retrieveWishlistWithCompletion:(void(^)(NSArray<GMSPlace*>*))completion {
    NSMutableArray<GMSPlace*>* places = [NSMutableArray new];
    for(Place* todo in self.wishlist)
    {
        // we need to query the place first
        PFQuery* query = [PFQuery queryWithClassName:@"Place"];
        [query getObjectInBackgroundWithId:todo.objectId
               block:^(PFObject * _Nullable result, NSError * _Nullable error)
               {
                   // now we can look it up in Google
                   [[APIManager shared] GMSPlaceFromPlace:(Place*)result
                                        withCompletion:^(GMSPlace *place)
                                        {
                                            [places addObject:place];
                                            
                                            // if we have looked up all of the places, return full array
                                            if(places.count == self.wishlist.count)
                                            {
                                                completion((NSArray*)places);
                                            }
                                        }
                    ];
               }
         ];
    }
}
@end
