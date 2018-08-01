//
//  FeedEvent.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FeedEvent.h"
#import "ListAdditionEvent.h"
#import "Place.h"

@implementation FeedEvent
- (instancetype)initWithParseObject:(PFObject *)object {
    self = [super init];
    self.parseObject = object;
    self.user = object[@"user"];
    self.place = object[@"place"];
    self.eventType = [object[@"eventType"] unsignedIntegerValue];
    
    return self;
}
- (void)setParseProperties {
    self.parseObject[@"user"] = self.user;
    self.parseObject[@"place"] = self.place;
    self.parseObject[@"eventType"] = [NSNumber numberWithUnsignedInteger:self.eventType];
}

- (void)saveInBackground {
    self.parseObject = [PFObject objectWithClassName:@"FeedEvent"];
    [self setParseProperties];
    [self.parseObject saveInBackground];
}

- (void)queryInfoWithCompletion:(void (^)(void))completion {
    PFQuery *userQuery = [PFUser query];
    [userQuery getObjectInBackgroundWithId:self.user.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.user = (PFUser *)object;
        PFQuery *placeQuery = [PFQuery queryWithClassName:@"Place"];
        [placeQuery getObjectInBackgroundWithId:self.place.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            self.place = (Place *)object;
            completion();
        }];
    }];
}
@end
