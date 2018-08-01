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
#import "Relationships.h"

@interface PFUser (ExtendedUser)
// Instance Properties //
@property NSString* displayName;
@property NSString* hometown;
@property NSString* bio;
@property PFFile* profilePicture;
@property NSArray<Place*> *favorites;
@property NSArray<Place*> *wishlist;
@property Relationships *relationships;
@property NSDictionary<NSString *, NSNumber *>*checkIns;

// Instance Methods //
- (void)addFavorite:(GMSPlace*)place;
- (void)removeFavorite:(GMSPlace*)place;
- (void)addToWishlist:(GMSPlace*)place;
- (void)removeFromWishlist:(GMSPlace*)place;
- (void)retrieveFavoritesWithCompletion:(void(^)(NSArray<GMSPlace*>*))completion;
- (void)retrieveWishlistWithCompletion:(void(^)(NSArray<GMSPlace*>*))completion;
- (void)follow:(PFUser *)user;
- (void)unfollow:(PFUser*)user;
- (void)retrieveRelationshipWithCompletion:(void(^)(Relationships*))completion;
+ (PFUser *)retrieveUserWithId:(NSString *)userId;
+ (void)retrieveUsersWithIDs:(NSArray<NSString*>*)IDs withCompletion:(void(^)(NSArray<PFUser*>*))completion;
- (void)addCheckIn:(NSString *)placeID withCompletion:(void(^)(void))completion;
- (void)retrieveCheckInCountForPlaceID:(NSString *)placeID withCompletion:(void(^)(NSNumber *))completion;
+ (void)getFollowingWithinUserArray:(NSArray <NSString*>*) objectIds withCompletion:(void(^)(NSArray <NSString*>*))completion;

@end
