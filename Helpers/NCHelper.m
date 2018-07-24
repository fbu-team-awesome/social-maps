//
//  NCHelper.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/23/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "NCHelper.h"

@implementation NCHelper
+ (void)addObserver:(nonnull id)observer type:(NotificationType)type selector:(SEL)selector {
    NSString* notification = [NCHelper stringWithNotificationType:type];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:notification object:nil];
}

+ (void)notify:(NotificationType)type object:(nullable id)object {
    NSString* notification = [NCHelper stringWithNotificationType:type];
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:object];
}

+ (NSString*)stringWithNotificationType:(NotificationType)type {
    switch(type)
    {
        case NTAddFavorite:
            return @"AddFavoriteNotification";
        case NTAddToWishlist:
            return @"AddToWishlistNotification";
        case NTNewFollow:
            return @"NewFollowNotification";
    }
    
    // throw an exception if we get here. It means there's no string equivalent of the NT.
    [NSException raise:@"Could not find NT enum string equivalent." format:@"'%lu' Notification Type has no string equivalent in 'stringWithNotificationType' method. NSNotificationCenter will fail.", type];
    return @"";
}
@end
