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
    if (self.checkbox.selected) {
        [self.checkbox setSelected:NO];
        [markerManager.typeFilters setValue:[NSNumber numberWithBool:NO] forKey:self.list];
        [markerManager.placeFilters setValue:[NSNumber numberWithBool:NO] forKey:self.list];
        [markerManager.allFilters setValue:[NSNumber numberWithBool:NO] forKey:self.list];
    }
    else {
        [self.checkbox setSelected:YES];
        [markerManager.typeFilters setValue:[NSNumber numberWithBool:YES] forKey:self.list];
        [markerManager.placeFilters setValue:[NSNumber numberWithBool:YES] forKey:self.list];
        [markerManager.allFilters setValue:[NSNumber numberWithBool:YES] forKey:self.list];
    }
}
@end
