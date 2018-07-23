//
//  PFUser+ExtendedUser.m
//  social-maps
//
//  Created by Britney Phan on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "PFUser+ExtendedUser.h"
#import <Parse/Parse.h>

@implementation PFUser (ExtendedUser)
@dynamic displayName, hometown, bio, profilePicture, favorites, wishlist, relationships;


- (void)addFavorite:(GMSPlace*)place {
    // check if place exists already
    [Place checkGMSPlaceExists:place
           result:^(Place* result)
           {
               // result should never be nil, but still check
               if(result != nil)
               {
                   if(![self.favorites containsObject:result])
                   {
                       [self.favorites addObject:result];
                       [self setObject:self.favorites forKey:@"favorites"];
                       [self saveInBackground];
                   }
                   else
                   {
                       NSLog(@"Already favorited.");
                   }
                }
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
               // result should never be nil, but still check
               if(result != nil)
               {
                   if(![self.wishlist containsObject:result])
                   {
                       [self.wishlist addObject:result];
                       [self setObject:self.wishlist forKey:@"wishlist"];
                       [self saveInBackground];
                   }
                   else
                   {
                       NSLog(@"Already wishlisted.");
                   }
               }
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

- (void)retrieveRelationshipWithCompletion:(void(^)(Relationships*))completion {
    
    PFQuery *query = [PFUser query];
    [query includeKey:@"relationships"];
    [query getObjectInBackgroundWithId:self.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        Relationships *thisRelationship = (Relationships *)object[@"relationships"];
        completion(thisRelationship);
    }];
}

- (void)follow:(PFUser *)user {

    // get the Relationships object of the current user
    [self retrieveRelationshipWithCompletion:^(Relationships *myRelationship) {
        
        // get the array of users the current user is following
        [Relationships retrieveFollowingWithId:self.relationships.objectId WithCompletion:^(NSArray *following) {
            
            self.relationships.following = [NSMutableArray arrayWithArray:following];
            
            [myRelationship addUserIdToFollowing:user.objectId];
        }];
    }];
    
    
    [user retrieveRelationshipWithCompletion:^(Relationships *userRelationship) {
        
        // get the array of user's followers
        [Relationships retrieveFollowersWithId:user.relationships.objectId WithCompletion:^(NSArray *followers) {
            
            [userRelationship addUserIdToFollowers:self.objectId];
            
            
        }];
        
    }];
}

- (void)unfollow:(PFUser*)user {
    // remove from our user
    [self retrieveRelationshipWithCompletion:
          ^(Relationships* myRelationship)
          {
              [myRelationship removeUserIDFromFollowing:user.objectId];
          }
     ];
    
    // remove from the other user
    [user retrieveRelationshipWithCompletion:
          ^(Relationships* theirRelationship)
          {
              [theirRelationship removeUserIDFromFollowers:self.objectId];
          }
     ];
}

+ (PFUser *)retrieveUserWithId:(NSString *)userId {
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:userId];
    PFUser *user = [[query findObjects] objectAtIndex:0];
    
    return user;
}

+ (void)retrieveUsersWithIDs:(NSArray<NSString*>*)IDs withCompletion:(void(^)(NSArray<PFUser*>*))completion {
    NSMutableArray<PFUser*>* users = [NSMutableArray new];
    
    // loop through all IDs
    for(NSString* ID in IDs)
    {
        PFQuery* query = [PFUser query];
        
        // query the ID
        [query getObjectInBackgroundWithId:ID
               block:^(PFObject * _Nullable object, NSError * _Nullable error)
               {
                   if(object != nil)
                   {
                       [users addObject:(PFUser*)object];
                   }
                   
                   // if our users array's length is the same as the IDs, then we are done
                   if(users.count == IDs.count)
                   {
                       completion((NSArray*)users);
                   }
               }
         ];
    }
}
@end
