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
#import "Photo.h"
#import "Relationships.h"

@interface Place : PFObject<PFSubclassing>
// Instance Properties //
@property (strong, nonatomic, nonnull) NSString *placeID;
@property (strong, nonatomic, nullable) NSString *placeName;
@property (strong, nonatomic, nullable) NSArray <NSString*> *checkIns;
@property (strong, nonatomic, nullable) NSDictionary<NSString *, NSArray<PFFile *> *> *photos;
@property (strong, nonatomic, nullable) NSDictionary<NSString *, NSArray<NSString *> *> *reviews;
@property (nonatomic) double rating;

- (nonnull instancetype)initWithGMSPlace:(nonnull GMSPlace*)place;
- (void) didCheckIn:(nonnull PFUser *)user;
- (void)getUsersCheckedInWithCompletion:(void(^ _Nonnull)(NSArray <NSString*>*_Nullable))completion;
+ (void)checkPlaceWithIDExists:(nonnull NSString *)placeID result:(void(^_Nonnull)(Place*_Nonnull))result;
+ (void)checkGMSPlaceExists:(nonnull GMSPlace*)place result:(void(^_Nonnull)(Place* _Nonnull))result;
- (void)addPhoto:(PFFile *_Nonnull)photo withCompletion:(void(^_Nullable)(void))completion;
- (void)retrievePhotosFromFollowing:(NSArray <NSString*>* _Nonnull)following withCompletion:(void(^ _Nonnull)(NSArray <Photo *>* _Nonnull))completion;
- (void)addReview:(NSString *_Nonnull)reviewId withCompletion:(void(^_Nullable)(void))completion;
- (void)retrieveReviewsFromFollowing:(NSArray <NSString*>* _Nonnull)following withCompletion:(void(^ _Nonnull)(NSArray <NSString *>* _Nonnull))completion;
    
@end

