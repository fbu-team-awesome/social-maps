//
//  PFUser+ExtendedUser.m
//  social-maps
//
//  Created by Britney Phan on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "PFUser+ExtendedUser.h"
#import <Parse/Parse.h>
#import "NCHelper.h"

@implementation PFUser (ExtendedUser)
@dynamic displayName, hometown, bio, profilePicture, favorites, wishlist, relationships, checkIns;

- (BOOL)isEqual:(id)object {
    return [self.objectId isEqualToString:((PFUser*)object).objectId];
}

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
                       NSMutableArray *mutableFavorites = [self.favorites mutableCopy];
                       [mutableFavorites addObject:result];
                       self.favorites = [mutableFavorites copy];
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
                   NSMutableArray *mutableFavorites = [self.favorites mutableCopy];
                   [mutableFavorites removeObject:result];
                   self.favorites = [mutableFavorites copy];
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
                       NSMutableArray *mutableWishlist = [self.wishlist mutableCopy];
                       [mutableWishlist addObject:result];
                       self.wishlist = [mutableWishlist copy];
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
                   NSMutableArray *mutableWishlist = [self.wishlist mutableCopy];
                   [mutableWishlist removeObject:result];
                   self.wishlist = [mutableWishlist copy];
               }
         
               [self setObject:self.wishlist forKey:@"wishlist"];
               [self saveInBackground];
           }
     ];
}

- (void)retrieveFavoritesWithCompletion:(void(^)(NSArray<GMSPlace*>*))completion {
    NSMutableArray<GMSPlace*>* places = [NSMutableArray new];
    
    // if we have no places, return an empty array
    if ([self.favorites count] == 0)
    {
        completion([NSArray arrayWithArray:places]);
    }
    
    // if we do have places, convert them all to GMSPlace
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
    
    // if we have no places, return an empty array
    if([self.favorites count] == 0)
    {
        completion([NSArray arrayWithArray:places]);
    }
    
    // if we do have places, convert them all to GMSPlace
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
            
            // send followed notification
            [NCHelper notify:NTNewFollow object:user];
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
              
              // send unfollow notification
              [NCHelper notify:NTUnfollow object:user];
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
    
    // if there are no IDs, return before
    if(IDs.count == 0)
    {
        completion([users copy]);
    }
    
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

+ (void)getFollowingWithinUserArray:(NSArray <NSString*>*) objectIds withCompletion:(void(^)(NSArray <NSString*>*))completion{
    [Relationships retrieveFollowingWithId:[PFUser currentUser].relationships.objectId WithCompletion:^(NSArray * _Nullable following) {
        NSMutableArray *mutableUsers = [[NSMutableArray alloc] init];
        NSSet *followingSet = [NSSet setWithArray:following];
        
        for (NSString *objectId in objectIds){
            if ([followingSet containsObject:objectId]) {
                [mutableUsers addObject:objectId];
            }
        }
        completion([mutableUsers copy]);
    }];
}

#pragma mark - Check-in Helper Methods

- (void)addCheckIn:(NSString *)placeID withCompletion:(void(^)(void))completion{
    //create a mutable copy
    NSMutableDictionary *newCheckIns = [self.checkIns mutableCopy];
    
    //if user has never checked into this place, add to checkIns with count 1
    if ([newCheckIns objectForKey:placeID] == nil) {
        [newCheckIns setObject:[NSNumber numberWithInteger:1] forKey:placeID];
    } else {
        int count = [newCheckIns[placeID] intValue] + 1;
        [newCheckIns setObject:[NSNumber numberWithInteger:count] forKey:placeID];
    }
    
    //set the dictionary to the mutable copy
    self.checkIns = [newCheckIns copy];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        completion();
    }];
    
}

- (void)retrieveCheckInCountForPlaceID:(NSString *)placeID withCompletion:(void(^)(NSNumber *))completion {
    PFQuery *query = [PFUser query];
    [query includeKey:@"checkIns"];
    
    //retrieves check-in count for placeID in user's checkIns dictionary
    [query getObjectInBackgroundWithId:self.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object == nil) {
            NSLog(@"Invalid user");
            completion(nil);
        } else {
            NSDictionary *checkIns = object[@"checkIns"];
            if ([checkIns objectForKey:placeID] == nil) {
                completion([NSNumber numberWithInteger:0]);
            } else {
                completion(checkIns[placeID]);
            }
        }
    }];
}

@end
