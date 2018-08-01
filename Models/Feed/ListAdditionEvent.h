//
//  ListAdditionEvent.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FeedEvent.h"

typedef enum ListType : NSUInteger
{
    LTFavorite,
    LTWishlist
}
ListType;

@interface ListAdditionEvent : FeedEvent
@property (nonatomic) ListType type;
@end
