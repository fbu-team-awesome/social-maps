//
//  MarkerManager.m
//  social-maps
//
//  Created by Bevin Benson on 7/27/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "MarkerManager.h"
#import "Marker.h"

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
    [self.markersByMarkerType setObject:[[NSMutableArray alloc] init] forKey:@"favorites"];
    [self.markersByMarkerType setObject:[[NSMutableArray alloc] init] forKey:@"wishlist"];
    [self.markersByMarkerType setObject:[[NSMutableArray alloc] init] forKey:@"followFavorite"];
    
    self.markersByPlaceType = [NSMutableDictionary new];
}

- (void)initDefaultFilters {
    self.filters = [NSMutableDictionary new];
    for (NSString *key in self.markersByMarkerType) {
        [self.filters setObject:[NSNumber numberWithBool:YES] forKey:key];
    }
    [self.filters setObject:[NSNumber numberWithBool:NO] forKey:@"favorites"];
    for (NSString *key in self.markersByPlaceType) {
        [self.filters setObject:[NSNumber numberWithBool:YES] forKey:key];
    }
}

- (void)addMarkerByType:(GMSMarker *)marker :(MarkerType)type {
    switch(type) {
        case favorites: {
            [[self.markersByMarkerType objectForKey:@"favorites"] addObject:marker];
            break;
        }
        case followFavorites: {
            [[self.markersByMarkerType objectForKey:@"followFavorite"] addObject:marker];
            break;
        }
        case wishlist: {
            [[self.markersByMarkerType objectForKey:@"wishlist"] addObject:marker];
            break;
        }
    }
}

#pragma - Add pins to dictionary based on type

- (GMSMarker *)setFavoritePin:(GMSPlace *)place {
    GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
    Marker *thisMarker = [[Marker alloc] initWithGMSPlace:place];
    
    marker.title = place.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.userData = thisMarker;
    
    [self addMarkerByType:marker :favorites];
    
    return marker;
}

- (GMSMarker *)setWishlistPin:(GMSPlace *)place {
    GMSMarker* marker = [GMSMarker markerWithPosition:place.coordinate];
    Marker *thisMarker = [[Marker alloc] initWithGMSPlace:place];
    
    marker.title = place.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    marker.userData = thisMarker;
    
    [self addMarkerByType:marker :wishlist];
    
    return marker;
}

- (GMSMarker *)setFavoriteOfFollowingPin:(GMSPlace *)place :(PFUser *)user {
    GMSMarker *marker = [GMSMarker markerWithPosition:place.coordinate];
    Marker *thisMarker = [[Marker alloc] initWithGMSPlace:place];
    
    marker.title = place.name;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    marker.userData = thisMarker;
    
    [self addMarkerByType:marker :followFavorites];
    
    return marker;
}
@end
