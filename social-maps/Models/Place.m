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
@end
