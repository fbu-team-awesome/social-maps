//
//  FollowEvent.h
//  social-maps
//
//  Created by César Francisco Barraza on 8/6/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FeedEvent.h"

@interface FollowEvent : FeedEvent
@property (strong, nonatomic) NSString *followingID;

- (instancetype)initWithParseObject:(PFObject *)object;
@end
