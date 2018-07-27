//
//  MarkerHelper.h
//  social-maps
//
//  Created by Bevin Benson on 7/26/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MarkerType : NSUInteger {
    favorites,
    wishlist,
    followFavorites
} MarkerType;

@interface MarkerHelper : NSObject

@end
