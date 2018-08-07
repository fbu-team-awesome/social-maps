//
//  FilterPill.h
//  social-maps
//
//  Created by Bevin Benson on 8/6/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "KBRoundedButton.h"

typedef enum FilterType : NSUInteger {
    favFilter,
    wishFilter,
    friendFilter,
    other
} FilterType;

@interface FilterPill : KBRoundedButton

@property FilterType filterType;
@property NSString *filterName;

@end
