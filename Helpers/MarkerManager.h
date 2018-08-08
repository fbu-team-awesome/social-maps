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
#import "Marker.h"

extern NSString *const kFavoritesKey;
extern NSString *const kWishlistKey;
extern NSString *const kFollowFavKey;

@interface MarkerManager : NSObject

@property (strong, nonatomic) NSMutableDictionary<NSString*, NSMutableArray<GMSMarker*>*> *markersByPlaceCategory;
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSMutableArray<GMSMarker*>*> *markersByMarkerType;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber*> *typeFilters;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *placeFilters;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSNumber *> *allFilters;
@property (strong, nonatomic) NSMutableArray<NSString *> *filterKeys;
@property (strong, nonatomic) NSDictionary<NSString *, NSArray *> *typeDict;
@property (strong, nonatomic) NSDictionary<NSString *, NSString *> *detailedTypeDict;
@property (strong, nonatomic) NSArray<NSString *> *placeCategories;

- (void)initMarkerDictionaries;
- (void)initDefaultFilters;
- (void)addMarkerByType:(GMSMarker *)marker :(MarkerType)type;
- (GMSMarker *)setFavoritePin:(GMSPlace *)place;
- (GMSMarker *)setWishlistPin:(GMSPlace *)place;
- (GMSMarker *)setFavoriteOfFollowingPin:(GMSPlace *)place :(PFUser *)user;

+ (instancetype)shared;

@end
