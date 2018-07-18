//
//  Place.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "Place.h"

@implementation Place
@dynamic placeID, placeName;

- (nonnull instancetype)initWithGMSPlace:(GMSPlace*)place {
    Place* newPlace = [Place object];
    newPlace.placeID = place.placeID;
    newPlace.placeName = place.name;
    
    return newPlace;
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
               result((Place*)object);
           }
     ];
}
@end
