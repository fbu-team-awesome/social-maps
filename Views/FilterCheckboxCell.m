//
//  FilterCheckboxCell.m
//  social-maps
//
//  Created by Bevin Benson on 7/31/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FilterCheckboxCell.h"
#import "MarkerManager.h"

@implementation FilterCheckboxCell

@synthesize selected;

- (void)configureCell {
    if ([self.list isEqualToString:kFollowFavKey]  || [self.list isEqualToString:kFavoritesKey]) {
        self.listName.text = @"Favorites";
    }
    else if ([self.list isEqualToString:kWishlistKey]) {
        self.listName.text = @"Wishlist";
    }
    else {
        self.listName.text = self.list;
    }
    
    if (self.selected) {
        [self.checkbox setSelected:YES];
    }
    else {
        [self.checkbox setSelected:NO];
    }
}

- (IBAction)checkboxTapped:(id)sender {
    MarkerManager *markerManager = [MarkerManager shared];
    NSDictionary *mutableTypeFilters = [markerManager.typeFilters mutableCopy];
    NSDictionary *mutablePlaceFilters = [markerManager.placeFilters mutableCopy];
    NSDictionary *mutableAllFilters = [markerManager.allFilters mutableCopy];
    if (self.checkbox.selected) {
        [self.checkbox setSelected:NO];
        [mutableTypeFilters setValue:[NSNumber numberWithBool:NO] forKey:self.list];
        [mutablePlaceFilters setValue:[NSNumber numberWithBool:NO] forKey:self.list];
        [mutableAllFilters setValue:[NSNumber numberWithBool:NO] forKey:self.list];
    }
    else {
        [self.checkbox setSelected:YES];
        [mutableTypeFilters setValue:[NSNumber numberWithBool:YES] forKey:self.list];
        [mutablePlaceFilters setValue:[NSNumber numberWithBool:YES] forKey:self.list];
        [mutableAllFilters setValue:[NSNumber numberWithBool:YES] forKey:self.list];
    }
    markerManager.typeFilters = [NSDictionary dictionaryWithDictionary:mutableTypeFilters];
    markerManager.placeFilters = [NSDictionary dictionaryWithDictionary:mutablePlaceFilters];
    markerManager.allFilters = [NSDictionary dictionaryWithDictionary:mutableAllFilters];
}
@end
