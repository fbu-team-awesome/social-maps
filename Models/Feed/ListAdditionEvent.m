//
//  ListAdditionEvent.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "ListAdditionEvent.h"

@implementation ListAdditionEvent
@synthesize listType;

- (void)saveParseObject {
    PFObject *object = [PFObject objectWithClassName:@"FeedEvent"];
    object[@"user"] = self.user;
    object[@"place"] = self.place;
    object[@"eventType"] = [NSNumber numberWithUnsignedInteger:self.eventType];
    object[@"listType"] = [NSNumber numberWithUnsignedInteger:self.listType];
    self.parseObject = object;
    
    [object saveInBackground];
}
@end
