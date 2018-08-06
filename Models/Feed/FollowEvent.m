//
//  FollowEvent.m
//  social-maps
//
//  Created by César Francisco Barraza on 8/6/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FollowEvent.h"

@implementation FollowEvent
- (instancetype)initWithParseObject:(PFObject *)object {
    if(self = [super initWithParseObject:object])
    {
        self.followerID = object[@"followerID"];
        self.followeeID = object[@"followeeID"];
    }
    
    return self;
}

- (void)setParseProperties {
    [super setParseProperties];
    self.parseObject[@"followerID"] = self.followerID;
    self.parseObject[@"followeeID"] = self.followeeID;
}
@end
