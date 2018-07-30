//
//  Review.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "Review.h"

@implementation Review
@dynamic user, content, rating;

+ (NSString *)parseClassName {
    return @"Review";
}
@end
