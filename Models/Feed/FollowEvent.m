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
        self.followingID = object[@"followingID"];
    }
    
    return self;
}

- (void)setParseProperties {
    [super setParseProperties];
    self.parseObject[@"followingID"] = self.followingID;
}

- (void)queryInfoWithCompletion:(void (^)(void))completion {
    PFQuery *userQuery = [PFUser query];
    [userQuery getObjectInBackgroundWithId:self.user.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.user = (PFUser *)object;
        completion();
    }];
}
@end
