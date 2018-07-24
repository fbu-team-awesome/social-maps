//
//  NCHelper.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/23/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum NotificationType : NSUInteger
{
    NTAddFavorite,
    NTAddToWishlist
}
NotificationType;

@interface NCHelper : NSObject
+ (void)addObserver:(nonnull id)observer type:(NotificationType)type selector:(SEL)selector;
+ (void)notify:(NotificationType)type object:(nullable id)object;
@end
