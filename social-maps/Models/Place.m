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
    self.placeID = place.placeID;
    self.placeName = place.name;
    
    return self;
}

+ (NSString*) parseClassName {
    return @"Place";
}
@end
