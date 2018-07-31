//
//  MarkerManager.h
//  social-maps
//
//  Created by Bevin Benson on 7/27/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <Parse/Parse.h>

typedef enum MarkerType : NSUInteger {
    favorites,
    wishlist,
    followFavorites
} MarkerType;

@interface MarkerManager : NSObject

@property (strong, nonatomic) NSMutableDictionary<NSString*, NSMutableArray<GMSMarker*>*> *markersByPlaceType;
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSMutableArray<GMSMarker*>*> *markersByMarkerType;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber*> *filters;

- (void)initMarkerDictionaries;
- (void)initDefaultFilters;
- (void)addMarkerByType:(GMSMarker *)marker :(MarkerType)type;
- (GMSMarker *)setFavoritePin:(GMSPlace *)place;
- (GMSMarker *)setWishlistPin:(GMSPlace *)place;
- (GMSMarker *)setFavoriteOfFollowingPin:(GMSPlace *)place :(PFUser *)user;

+ (instancetype)shared;

@end
