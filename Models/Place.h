//
//  Place.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Parse/Parse.h>
#import <GooglePlaces/GooglePlaces.h>
#import "Review.h"

@interface Place : PFObject<PFSubclassing>
// Instance Properties //
@property (strong, nonatomic, nonnull) NSString *placeID;
@property (strong, nonatomic, nullable) NSString *placeName;
@property (strong, nonatomic, nullable) NSArray <NSString*> *checkIns;
@property (strong, nonatomic, nullable) NSDictionary<NSString *, NSArray<PFFile *> *> *photos;
@property (strong, nonatomic, nullable) NSDictionary<NSString *, NSArray<Review *> *> *reviews;
@property (nonatomic) double rating;

- (nonnull instancetype)initWithGMSPlace:(nonnull GMSPlace*)place;
- (void) didCheckIn:(nonnull PFUser *)user;
- (void)getUsersCheckedInWithCompletion:(void(^ _Nonnull)(NSArray <NSString*>*_Nullable))completion;
- (void)addReviewFromUser:(PFUser *)user withContent:(NSString *)content withRating:(int)rating withCompletion:(void(^)(void))completion;

+ (void)checkPlaceWithIDExists:(nonnull NSString *)placeID result:(void(^_Nonnull)(Place*_Nonnull))result;
+ (void)checkGMSPlaceExists:(nonnull GMSPlace*)place result:(void(^_Nonnull)(Place* _Nonnull))result;

@end

