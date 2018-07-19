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
    // check if place exists already
    [Place checkGMSPlaceExists:place
           result:^(Place* result)
           {
               if(result != nil)
               {
                   // it exists already. No need to create a new one.
                   [self.favorites addObject:result];
               }
               else
               {
                   // doesn't exist yet. Create a new one
                   Place* newPlace = [[Place alloc] initWithGMSPlace:place];
                   [self.favorites addObject:newPlace];
               }
         
               [self setObject:self.favorites forKey:@"favorites"];
               [self saveInBackground];
           }
     ];
}

- (void)removeFavorite:(GMSPlace*)place {
    // check if place exists in the database
    [Place checkGMSPlaceExists:place
           result:^(Place* result)
           {
               if(result != nil)
               {
                   [self.favorites removeObject:result];
               }
         
               [self setObject:self.favorites forKey:@"favorites"];
               [self saveInBackground];
           }
     ];
}

- (void)addToWishlist:(GMSPlace*)place {
    // check if place exists already
    [Place checkGMSPlaceExists:place
           result:^(Place* result)
           {
               if(result != nil)
               {
                   // it exists already. No need to create a new one.
                   [self.wishlist addObject:result];
               }
               else
               {
                   // doesn't exist yet. Create a new one
                   Place* newPlace = [[Place alloc] initWithGMSPlace:place];
                   [self.wishlist addObject:newPlace];
               }
         
               [self setObject:self.wishlist forKey:@"wishlist"];
               [self saveInBackground];
           }
     ];
}

- (void)removeFromWishlist:(GMSPlace*)place {
    // check if place exists in the database
    [Place checkGMSPlaceExists:place
           result:^(Place* result)
           {
               if(result != nil)
               {
                   [self.wishlist removeObject:result];
               }
         
               [self setObject:self.wishlist forKey:@"wishlist"];
               [self saveInBackground];
           }
     ];
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
