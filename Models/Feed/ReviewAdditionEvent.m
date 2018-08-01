//
//  ReviewAdditionEvent.m
//  social-maps
//
//  Created by César Francisco Barraza on 8/1/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "ReviewAdditionEvent.h"

@implementation ReviewAdditionEvent
- (instancetype)initWithParseObject:(PFObject *)object {
    if(self = [super initWithParseObject:object])
    {
        self.review = object[@"review"];
    }
    
    return self;
}

- (void)setParseProperties {
    [super setParseProperties];
    self.parseObject[@"review"] = self.review;
}
@end
