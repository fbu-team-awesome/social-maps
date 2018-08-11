//
//  FilterPillHelper.h
//  social-maps
//
//  Created by Bevin Benson on 8/7/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FilterPillView.h"

@interface FilterPillHelper : NSObject

- (FilterPillView * _Nonnull)createFilterPill:(FilterType)type withName:(NSString * _Nullable)filterName;

+ (nonnull instancetype)shared;


@end
