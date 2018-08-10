//
//  Marker.m
//  social-maps
//
//  Created by Bevin Benson on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "Marker.h"

@implementation Marker

- (instancetype)initWithGMSPlace:(GMSPlace *)place markerType:(MarkerType)type user:(PFUser*)user{
    self = [super init];
    if (self) {
        self.place = place;
        self.types = place.types;
        self.type = type;
        self.markerOwner = user;
    }
    return self;
}

+ (void)setMarkerImageWithGMSMarker:(GMSMarker *)marker {
    Marker *thisMarker = marker.userData;
    if (thisMarker.type == favorites)  {
        UIImage *favMarkerIcon = [UIImage imageNamed:@"favorites_marker_icon"];
        marker.icon = favMarkerIcon;
    }
    else if (thisMarker.type == wishlist) {
        UIImage *wishlistMarkerIcon = [UIImage imageNamed:@"wishlist_marker_icon"];
        marker.icon = wishlistMarkerIcon;
    }
    else if (thisMarker.type == followFavorites) {
        UIImage *friendsMarkerIcon = [UIImage imageNamed:@"friends_marker_icon"];
        marker.icon = friendsMarkerIcon;
    }
}

@end
