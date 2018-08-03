//
//  Marker.h
//  social-maps
//
//  Created by Bevin Benson on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlaces/GooglePlaces.h>
#import "PFUser+ExtendedUser.h"

typedef enum MarkerType : NSUInteger {
    favorites,
    wishlist,
    followFavorites
} MarkerType;

@interface Marker : NSObject

- (instancetype)initWithGMSPlace:(GMSPlace *)place markerType:(MarkerType)type user:(PFUser*)user;

@property (strong, nonatomic) GMSPlace *place;
@property (strong, nonatomic) NSArray *types;
@property (nonatomic) MarkerType type;
@property (strong, nonatomic) PFUser *markerOwner;

@end
