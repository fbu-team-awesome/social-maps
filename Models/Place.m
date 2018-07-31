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
@dynamic placeID, placeName, checkIns;

- (nonnull instancetype)initWithGMSPlace:(GMSPlace*)place {
    Place *newPlace = [Place object];
    newPlace.placeID = place.placeID;
    newPlace.placeName = place.name;
    newPlace.checkIns = [NSArray new];
    
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

@end
