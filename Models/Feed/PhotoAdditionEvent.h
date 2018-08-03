//
//  PhotoAdditionEvent.h
//  social-maps
//
//  Created by César Francisco Barraza on 8/1/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FeedEvent.h"

@interface PhotoAdditionEvent : FeedEvent
@property (strong, nonatomic) PFFile *photo;

- (instancetype)initWithParseObject:(PFObject *)object;
@end
