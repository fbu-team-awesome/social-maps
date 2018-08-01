//
//  FeedEvent.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Parse/Parse.h>
#import "PFUser+ExtendedUser.h"
#import "Place.h"

typedef enum FeedEventType : NSUInteger
{
    ETCheckin,
    ETListAddition
}
FeedEventType;

@interface FeedEvent : NSObject
@property (strong, nonatomic) PFObject *parseObject;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) Place *place;
@property (nonatomic) FeedEventType eventType;

- (instancetype)initWithParseObject:(PFObject *)object;
- (void)setParseProperties;
- (void)saveInBackground;
- (void)queryInfoWithCompletion:(void(^)(void))completion;
@end
