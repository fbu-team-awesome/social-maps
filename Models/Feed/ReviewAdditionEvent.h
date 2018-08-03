//
//  ReviewAdditionEvent.h
//  social-maps
//
//  Created by César Francisco Barraza on 8/1/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FeedEvent.h"

@interface ReviewAdditionEvent : FeedEvent
@property (strong, nonatomic) Review *review;

- (instancetype)initWithParseObject:(PFObject *)object;
@end
