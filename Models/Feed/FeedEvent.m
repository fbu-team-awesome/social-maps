//
//  FeedEvent.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FeedEvent.h"

@implementation FeedEvent
@dynamic user, place;

+ (NSString *)parseClassName {
    return @"FeedEvent";
}
@end
