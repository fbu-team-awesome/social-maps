//
//  FilterPillHelper.h
//  social-maps
//
//  Created by Bevin Benson on 8/7/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum FilterType : NSUInteger {
    favFilter,
    wishFilter,
    friendFilter,
    placeFilter
} FilterType;

@interface FilterPillHelper : NSObject

+ (UIView * _Nonnull)createFilterPill:(FilterType)type withName:(NSString * _Nullable)filterName;

@end
