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
    FeedEventType eventType = [object[@"eventType"] unsignedIntegerValue];

    if(eventType == ETListAddition)
    {
        ListAdditionEvent *event = [[ListAdditionEvent alloc] init];
        event.user = object[@"user"];
        event.place = object[@"place"];
        event.eventType = eventType;
        event.listType = [object[@"listType"] unsignedIntegerValue];
        event.parseObject = object;
        
        return (FeedEvent *)event;
    }
    else if(eventType == ETCheckin)
    {
        
    }
    
    // otherwise, init normally
    self = [super init];
    if(self)
    {
        self.user = object[@"user"];
        self.place = object[@"place"];
        self.eventType = [object[@"eventType"] unsignedIntegerValue];
    }
    
    return self;
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
