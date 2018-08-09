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
    self.markersByMarkerType = [NSMutableDictionary new];
    [self.markersByMarkerType setObject:[[NSMutableArray alloc] init] forKey:kFavoritesKey];
    [self.markersByMarkerType setObject:[[NSMutableArray alloc] init] forKey:kWishlistKey];
    [self.markersByMarkerType setObject:[[NSMutableArray alloc] init] forKey:kFollowFavKey];
    
    self.typeDict = @{
                      @"Entertainment":@[@"amusement_park", @"aquarium", @"casino", @"movie_theater", @"bowling_alley", @"zoo", @"night_club"],
                      @"Restaurants":@[@"restaurant", @"meal_delivery", @"meal_takeaway"], @"Cafés":@[@"cafe", @"bakery"],
                      @"Shopping":@[@"clothing_store", @"department_store", @"home_goods_store", @"shopping_mall", @"shoe_store", @"furniture_store"],
                      @"Outdoors":@[@"park", @"campground", @"rv_park"],
                      @"Beauty":@[@"beauty_salon", @"hair_care"],
                      @"Museums":@[@"art_gallery", @"museum"]
                      };
    self.placeCategories = [self.typeDict allKeys];
    self.markersByPlaceCategory = [NSMutableDictionary new];
    for (NSString *key in self.placeCategories) {
        [self.markersByPlaceCategory setObject:[NSMutableArray new] forKey:key];
    }
    
    // Reverse typeDict so that each Google Place type is mapped to its category name
    NSMutableDictionary *mutableDetailedTypeDict = [NSMutableDictionary new];
    for (NSString *key in self.placeCategories) {
        [self.markersByPlaceCategory setObject:[[NSMutableArray alloc] init] forKey:key];
        NSArray *arrayOfGTypes = [self.typeDict objectForKey:key];
        for (NSString *type in arrayOfGTypes) {
            [mutableDetailedTypeDict setObject:key forKey:type];
        }
    }
    self.detailedTypeDict = (NSDictionary *)mutableDetailedTypeDict;
}

- (void)initDefaultFilters {
    self.typeFilters = [NSMutableDictionary new];
    self.placeFilters = [NSMutableDictionary new];
    self.allFilters = [NSMutableDictionary new];
    self.filterKeys = [NSMutableArray new];
    for (NSString *key in self.markersByMarkerType) {
        [self.typeFilters setObject:[NSNumber numberWithBool:YES] forKey:key];
        [self.allFilters setObject:[NSNumber numberWithBool:YES] forKey:key];
        [self.filterKeys addObject:key];
    }
    for (NSString *key in self.markersByPlaceCategory) {
        [self.placeFilters setObject:[NSNumber numberWithBool:YES] forKey:key];
        [self.allFilters setObject:[NSNumber numberWithBool:YES] forKey:key];
    }
    
    NSArray *orderedPlaceKeys = @[@"Restaurants", @"Cafés", @"Entertainment", @"Shopping", @"Outdoors", @"Beauty", @"Museums"];
    [self.filterKeys addObjectsFromArray:orderedPlaceKeys];
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
    }
}

- (void)addMarkerByPlaceTypes:(GMSMarker *)marker :(GMSPlace *)place {
    for (NSString *type in place.types) {
        NSString *categoryName = [self.detailedTypeDict objectForKey:type];
        [[self.markersByPlaceCategory objectForKey:categoryName] addObject:marker];
    }
}
@end
