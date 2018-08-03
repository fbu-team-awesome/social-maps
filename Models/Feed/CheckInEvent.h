//
//  CheckInEvent.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FeedEvent.h"

@interface CheckInEvent : FeedEvent
- (instancetype)initWithParseObject:(PFObject *)object;
@end
