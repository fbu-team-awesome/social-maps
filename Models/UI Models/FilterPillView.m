//
//  FilterPillView.m
//  social-maps
//
//  Created by Bevin Benson on 8/9/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FilterPillView.h"

@implementation FilterPillView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)setId {
    self.viewId = [NSString stringWithFormat:@"%@%@", self.filterName, [[NSNumber numberWithInt:self.filterType] stringValue]];
}

@end
