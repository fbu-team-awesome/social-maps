//
//  PhotoAdditionEvent.m
//  social-maps
//
//  Created by César Francisco Barraza on 8/1/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "PhotoAdditionEvent.h"

@implementation PhotoAdditionEvent
- (instancetype)initWithParseObject:(PFObject *)object {
    if(self = [super initWithParseObject:object])
    {
        self.photo = object[@"photo"];
    }
    
    return self;
}

- (void)setParseProperties {
    [super setParseProperties];
    self.parseObject[@"photo"] = self.photo;
}
@end
