//
//  ListAdditionEvent.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "ListAdditionEvent.h"

@implementation ListAdditionEvent
- (instancetype)initWithParseObject:(PFObject *)object {
    self = [super initWithParseObject:object];
    self.listType = [object[@"listType"] unsignedIntegerValue];
    
    return self;
}

- (void)setParseProperties {
    [super setParseProperties];
    self.parseObject[@"listType"] = [NSNumber numberWithUnsignedInteger:self.listType];
}
@end
