//
//  MarkerManager.m
//  social-maps
//
//  Created by Bevin Benson on 7/27/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "MarkerManager.h"
#import "Marker.h"

NSString *const kFavoritesKey = @"favorites";
NSString *const kWishlistKey = @"wishlist";
NSString *const kFollowFavKey = @"followFavorites";

@implementation MarkerManager
+ (instancetype)shared {
    static MarkerManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (void)initMarkerDictionaries {
    self.markersByMarkerType = [NSDictionary new];
    NSMutableDictionary *mutableMarkersByMarkerType = [self.markersByMarkerType mutableCopy];
    [mutableMarkersByMarkerType setObject:[[NSMutableArray alloc] init] forKey:kFavoritesKey];
    [mutableMarkersByMarkerType setObject:[[NSMutableArray alloc] init] forKey:kWishlistKey];
    [mutableMarkersByMarkerType setObject:[[NSMutableArray alloc] init] forKey:kFollowFavKey];
    self.markersByMarkerType = [[NSDictionary alloc] initWithDictionary:mutableMarkersByMarkerType];
    
    self.typeDict = @{
                      @"Entertainment":@[@"amusement_park", @"aquarium", @"casino", @"movie_theater", @"bowling_alley", @"zoo", @"night_club"],
                      @"Restaurants":@[@"restaurant", @"meal_delivery", @"meal_takeaway"], @"Cafés":@[@"cafe", @"bakery"],
                      @"Shopping":@[@"clothing_store", @"department_store", @"home_goods_store", @"shopping_mall", @"shoe_store", @"furniture_store"],
                      @"Outdoors":@[@"park", @"campground", @"rv_park"],
                      @"Beauty":@[@"beauty_salon", @"hair_care"],
                      @"Museums":@[@"art_gallery", @"museum"]
                      };
    
    self.placeCategories = [self.typeDict allKeys];
    self.markersByPlaceCategory = [NSDictionary new];
    NSMutableDictionary *mutableMarkersByPlaceCategory = [self.markersByPlaceCategory mutableCopy];
    for (NSString *key in self.placeCategories) {
        [mutableMarkersByPlaceCategory setObject:[NSMutableArray new] forKey:key];
    }
    
    // Reverse typeDict so that each Google Place type is mapped to its category name
    NSMutableDictionary *mutableDetailedTypeDict = [NSMutableDictionary new];
    for (NSString *key in self.placeCategories) {
        [mutableMarkersByPlaceCategory setObject:[[NSMutableArray alloc] init] forKey:key];
        NSArray *arrayOfGTypes = [self.typeDict objectForKey:key];
        for (NSString *type in arrayOfGTypes) {
            [mutableDetailedTypeDict setObject:key forKey:type];
        }
    }
    self.detailedTypeDict = [[NSDictionary alloc] initWithDictionary:mutableDetailedTypeDict];
    self.markersByPlaceCategory = [[NSDictionary alloc] initWithDictionary:mutableMarkersByPlaceCategory];
}

- (void)initDefaultFilters {
    self.typeFilters = [NSDictionary new];
    self.placeFilters = [NSDictionary new];
    self.allFilters = [NSDictionary new];
    self.filterKeys = [NSArray new];
    NSMutableDictionary  *mutableTypeFilters = [NSMutableDictionary new];
    NSMutableDictionary *mutablePlaceFilters = [NSMutableDictionary new];
    NSMutableDictionary *mutableAllFilters = [NSMutableDictionary new];
    NSMutableArray *mutableFilterKeys = [NSMutableArray new];
    for (NSString *key in self.markersByMarkerType) {
        [mutableTypeFilters setObject:[NSNumber numberWithBool:YES] forKey:key];
        [mutableAllFilters setObject:[NSNumber numberWithBool:YES] forKey:key];
        [mutableFilterKeys addObject:key];
    }
    for (NSString *key in self.markersByPlaceCategory) {
        [mutablePlaceFilters setObject:[NSNumber numberWithBool:YES] forKey:key];
        [mutableAllFilters setObject:[NSNumber numberWithBool:YES] forKey:key];
    }
    
    NSArray *orderedPlaceKeys = @[@"Restaurants", @"Cafés", @"Entertainment", @"Shopping", @"Outdoors", @"Beauty", @"Museums"];
    [mutableFilterKeys addObjectsFromArray:orderedPlaceKeys];
    self.typeFilters = [[NSDictionary alloc] initWithDictionary:mutableTypeFilters];
    self.placeFilters = [[NSDictionary alloc] initWithDictionary:mutablePlaceFilters];
    self.allFilters = [[NSDictionary alloc] initWithDictionary:mutableAllFilters];
    self.filterKeys = [[NSArray alloc] initWithArray:mutableFilterKeys];
}

#pragma mark - Create the markers

- (GMSMarker *)setFavoritePin:(GMSPlace *)place {
    GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
    Marker *thisMarker = [[Marker alloc] initWithGMSPlace:place markerType:favorites user:[PFUser currentUser]];
    
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.userData = thisMarker;
    
    [self addMarkerByType:marker :favorites];
    [self addMarkerByPlaceTypes:marker :place];
    
    return marker;
}

- (GMSMarker *)setWishlistPin:(GMSPlace *)place {
    GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
    Marker *thisMarker = [[Marker alloc] initWithGMSPlace:place markerType:wishlist user:[PFUser currentUser]];
    
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    marker.userData = thisMarker;
    
    [self addMarkerByType:marker :wishlist];
    [self addMarkerByPlaceTypes:marker :place];
    
    return marker;
}

- (GMSMarker *)setFavoriteOfFollowingPin:(GMSPlace *)place :(PFUser *)user {
    GMSMarker *marker = [GMSMarker markerWithPosition:place.coordinate];
    Marker *thisMarker = [[Marker alloc] initWithGMSPlace:place markerType:followFavorites user:user];
    
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    marker.userData = thisMarker;
    
    [self addMarkerByType:marker :followFavorites];
    [self addMarkerByPlaceTypes:marker :place];
    
    return marker;
}

#pragma mark - Add marker to dictionary based on type

- (void)addMarkerByType:(GMSMarker *)marker :(MarkerType)type {
    switch(type) {
        case favorites: {
            [[self.markersByMarkerType objectForKey:kFavoritesKey] addObject:marker];
            break;
        }
        case followFavorites: {
            [[self.markersByMarkerType objectForKey:kFollowFavKey] addObject:marker];
            break;
        }
        case wishlist: {
            [[self.markersByMarkerType objectForKey:kWishlistKey] addObject:marker];
            break;
        }
        case other: {
            break;
        }
    }
}

- (void)addMarkerByPlaceTypes:(GMSMarker *)marker :(GMSPlace *)place {
    for (NSString *type in place.types) {
        NSString *categoryName = [self.detailedTypeDict objectForKey:type];
        [[self.markersByPlaceCategory objectForKey:categoryName] addObject:marker];
    }
}
@end
