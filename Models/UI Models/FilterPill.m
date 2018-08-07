//
//  FilterPill.m
//  social-maps
//
//  Created by Bevin Benson on 8/6/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FilterPill.h"

@implementation FilterPill

- (instancetype)initWithFrame:(CGRect)frame :(FilterType)filterType :(NSString  * _Nullable )filterName{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.filterType = filterType;
        self.filterName = filterName;
        [self initButton];
    }
    return self;
}

- (void)initButton {
    switch(self.filterType) {
        case favFilter: {
            [self setBackgroundColorForStateNormal:[UIColor colorNamed:@"VTR_Orange"]];
            self.titleLabel.text = @"Favorites";
        }
        case wishFilter: {
            [self setBackgroundColorForStateNormal:[UIColor colorNamed:@"VTR_Secondary"]];
            self.titleLabel.text = @"Wishlist";
        }
        case friendFilter: {
            [self setBackgroundColorForStateNormal:[UIColor colorNamed:@"VTR_Blue"]];
            self.titleLabel.text = @"Friends";
        }
        case other: {
            [self setBackgroundColorForStateNormal:[UIColor grayColor]];
            if (self.filterName) {
                self.titleLabel.text = self.filterName;
            }
        }
    }
}

@end
