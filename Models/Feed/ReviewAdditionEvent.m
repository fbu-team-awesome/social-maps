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

- (void)queryInfoWithCompletion:(void (^)(void))completion {
    PFQuery *userQuery = [PFUser query];
    [userQuery getObjectInBackgroundWithId:self.user.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.user = (PFUser *)object;
        
        PFQuery *placeQuery = [PFQuery queryWithClassName:@"Place"];
        [placeQuery getObjectInBackgroundWithId:self.place.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            self.place = (Place *)object;
            
            PFQuery *reviewQuery = [PFQuery queryWithClassName:@"Review"];
            [reviewQuery getObjectInBackgroundWithId:self.review.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
                self.review = (Review *)object;
                completion();
            }];
        }];
    }];
}
@end
