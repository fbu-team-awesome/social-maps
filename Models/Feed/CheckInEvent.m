//
//  CheckInEvent.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "CheckInEvent.h"

@implementation CheckInEvent
- (instancetype)initWithParseObject:(PFObject *)object {
    self = [super initWithParseObject:object];
    self.photos = object[@"photos"];
    self.review = object[@"review"];
    
    return self;
}

- (void)setParseProperties {
    [super setParseProperties];
    self.parseObject[@"photos"] = self.photos;
    self.parseObject[@"review"] = self.review;
}
@end
