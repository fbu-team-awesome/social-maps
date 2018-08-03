//
//  Marker.m
//  social-maps
//
//  Created by Bevin Benson on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "Marker.h"

@implementation Marker

- (instancetype)initWithGMSPlace:(GMSPlace *)place {
    self = [super init];
    if (self) {
        self.place = place;
        self.types = place.types;
    }
    return self;
}

@end
