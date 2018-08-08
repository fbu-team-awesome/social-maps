//
//  Place.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "Place.h"
#import "APIManager.h"

@implementation Place
@dynamic placeID, placeName, checkIns, photos, reviews, rating;

- (nonnull instancetype)initWithGMSPlace:(GMSPlace*)place {
    Place *newPlace = [Place object];
    newPlace.placeID = place.placeID;
    newPlace.placeName = place.name;
    newPlace.checkIns = [NSArray new];
    newPlace.photos = [NSDictionary new];
    newPlace.reviews = [NSDictionary new];
    newPlace.rating = 0;
 
    return newPlace;
}

- (BOOL)isEqual:(id)object {
    return [self.objectId isEqualToString:((Place*)object).objectId];
}

+ (NSString*) parseClassName {
    return @"Place";
}

+ (void)checkGMSPlaceExists:(GMSPlace*)place result:(void(^)(Place*))result {
    PFQuery* query = [PFQuery queryWithClassName:@"Place"];
    [query whereKey:@"placeID" equalTo:place.placeID];
    [query getFirstObjectInBackgroundWithBlock:
           ^(PFObject * _Nullable object, NSError * _Nullable error)
           {
               // if it doesnt exist, create it
               if (object == nil)
               {
                   Place* newPlace = [[Place alloc] initWithGMSPlace:place];
                   result(newPlace);
               }
               else
               {
                   result((Place*)object);
               }
           }
     ];
}
+ (void)checkPlaceWithIDExists:(NSString *)placeID result:(void(^)(Place*))result {
    PFQuery* query = [PFQuery queryWithClassName:@"Place"];
    [query whereKey:@"placeID" equalTo:placeID];
    [query getFirstObjectInBackgroundWithBlock:
           ^(PFObject * _Nullable object, NSError * _Nullable error)
           {
               // if it doesnt exist, create it
               if (object == nil)
               {
                   [[APIManager shared] GMSPlaceFromID:placeID
                                        withCompletion:^(GMSPlace *place)
                                        {
                                            Place *newPlace = [[Place alloc] initWithGMSPlace:place];
                                            result(newPlace);
                                        }
                    ];
               }
               else
               {
                   result((Place*)object);
               }
           }
     ];
}

- (void)didCheckIn:(PFUser *)user {
    [self addObject:user.objectId forKey:@"checkIns"];
    [self saveInBackground];
}

- (void)getUsersCheckedInWithCompletion:(void(^)(NSArray <NSString*>*))completion {
    PFQuery* query = [PFQuery queryWithClassName:@"Place"];
    [query getObjectInBackgroundWithId:self.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            completion(object[@"checkIns"]);
        }
    }];
}

- (void)addPhoto:(PFFile *)photo withCompletion:(void(^)(void))completion{
    //create a mutable copy
    NSMutableDictionary *newPhotos = [self.photos mutableCopy];
    
    //if user has never added photos to this place, add to photos array
    if ([newPhotos objectForKey:PFUser.currentUser.objectId] == nil) {
        NSArray *newPhotosArray = [NSArray arrayWithObject:photo];
        [newPhotos setObject:newPhotosArray forKey:PFUser.currentUser.objectId];
    }
    //else add to existing photos array
    else {
        NSArray *photosArray = [newPhotos[PFUser.currentUser.objectId] arrayByAddingObject:photo];
        [newPhotos setObject:photosArray forKey:PFUser.currentUser.objectId];
    }
    
    //set the photos dictionary to the mutable copy
    self.photos = [newPhotos copy];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        completion();
    }];
}

- (void)retrievePhotosFromFollowing:(NSArray <NSString*>*)following withCompletion:(void(^)(NSArray <Photo *>*))completion {
    //iterate through following list to add dictionary pairs to new dictionary
    NSMutableDictionary *filteredPlacePhotos = [[NSMutableDictionary alloc] init];
    for (NSString *followingId in following) {
        if ([self.photos objectForKey:followingId] != nil) {
            [filteredPlacePhotos setObject:[self.photos objectForKey:followingId] forKey:followingId];
        }
    }
    
    //also add current user's photos
    if ([self.photos objectForKey:PFUser.currentUser.objectId]) {
        [filteredPlacePhotos setObject:[self.photos objectForKey:PFUser.currentUser.objectId] forKey:PFUser.currentUser.objectId];
    }
    //iterate through dictionary to put objects in a new Photo array
    NSMutableArray <Photo *> *followingPhotos = [NSMutableArray new];
    for (NSString *followingId in [filteredPlacePhotos allKeys]) {
        //create Photo objects for every photo and add to new array
        for (PFFile *file in filteredPlacePhotos[followingId]) {
            Photo *newPhoto = [[Photo alloc] initWithPFFile:file userObjectId:followingId];
            [followingPhotos addObject:newPhoto];
        }
    }
    completion([followingPhotos copy]);
}

- (void)addReview:(Review *)review withCompletion:(void(^)(void))completion {
    //create a mutable copy
    NSMutableDictionary *newReviews = [self.reviews mutableCopy];
    
    //if user has never added reviews to this place, add to new reviews array
    if ([newReviews objectForKey:PFUser.currentUser.objectId] == nil) {
        NSArray *newReviewsArray = [NSArray arrayWithObject:review];
        [newReviews setObject:newReviewsArray forKey:PFUser.currentUser.objectId];
    }
    //else add to existing reviews array
    else {
        NSArray *reviewsArray = [newReviews[PFUser.currentUser.objectId] arrayByAddingObject:review];
        [newReviews setObject:reviewsArray forKey:PFUser.currentUser.objectId];
    }
    
    //set the reviews dictionary to the mutable copy
    self.reviews = [newReviews copy];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        completion();
    }];
}

- (void)retrieveReviewsFromFollowing:(NSArray <NSString*>*)following withCompletion:(void(^)(NSArray <Review *>*))completion {
    //iterate through following list to add dictionary pairs to new dictionary
    NSMutableDictionary <NSString *, NSArray<Review *>*> *filteredPlaceReviews = [[NSMutableDictionary alloc] init];
    for (NSString *followingId in following) {
        if ([self.reviews objectForKey:followingId] != nil) {
            [filteredPlaceReviews setObject:[self.reviews objectForKey:followingId] forKey:followingId];
        }
    }
    
    //also add current user's reviews
    if ([self.reviews objectForKey:PFUser.currentUser.objectId]) {
        [filteredPlaceReviews setObject:[self.reviews objectForKey:PFUser.currentUser.objectId] forKey:PFUser.currentUser.objectId];
    }

    //iterate through dictionary to put objects in a new Photo array
    __block NSMutableArray <Review *> *followingReviews = [NSMutableArray new];
    NSMutableArray <Review *> *totalReviews = [NSMutableArray new];
    __block long userCount = 0;
    for (NSString *followingId in [filteredPlaceReviews allKeys]) {
        for (Review *review in filteredPlaceReviews[followingId]) {
            PFQuery *query = [PFQuery queryWithClassName:@"Review"];
            [query includeKey:@"user"];
            [query getObjectInBackgroundWithId:review.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
                Review *newReview = (Review *)object;
                [followingReviews addObject:newReview];
                //if we have added all reviews, add this user to our userCount
                
                if (followingReviews.count == filteredPlaceReviews[followingId].count) {
                    userCount++;
                    [totalReviews addObjectsFromArray:followingReviews];
                    followingReviews = [NSMutableArray new];
                    
                    if (userCount == [filteredPlaceReviews allKeys].count) {
                        completion([totalReviews copy]);
                    }
                }
            }];
        }
    }
    
}
@end
