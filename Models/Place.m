//
//  Place.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "Place.h"
#import "APIManager.h"
#import "ReviewAdditionEvent.h"

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

- (void)addReviewFromUser:(PFUser *)user withContent:(NSString *)content withRating:(int)rating withCompletion:(void (^)(void))completion {
    [Review reviewWithUser:user withContent:content withRating:rating
            withCompletion:^(Review *review) {
                NSMutableDictionary *mutableDict = [self.reviews mutableCopy];
        
                if(mutableDict[user.objectId] == nil)
                {
                    NSArray<Review *> *reviewArray = [NSArray arrayWithObject:review];
                    mutableDict[user.objectId] = reviewArray;
                }
                else
                {
                    mutableDict[user.objectId] = [[NSArray arrayWithObject:review] arrayByAddingObjectsFromArray:mutableDict[user.objectId]];
                }
                
                self.reviews = [mutableDict copy];
                [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    // create the feed event
                    ReviewAdditionEvent *event = [ReviewAdditionEvent new];
                    event.user = user;
                    event.eventType = ETReviewAddition;
                    event.review = review;
                    event.place = self;
                    [event saveInBackground];
                    completion();
                }];
    }];
}
@end
