//
//  FilterPillView.h
//  social-maps
//
//  Created by Bevin Benson on 8/9/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum FilterType : NSUInteger {
    favFilter,
    wishFilter,
    friendFilter,
    placeFilter
} FilterType;

@interface FilterPillView : UIView

@property (strong, nonatomic) NSString *filterName;
@property (nonatomic, assign) FilterType filterType;

@property (strong, nonatomic) NSString *viewId;

- (void)setId;

@end
