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

+ (void)reviewWithUser:(PFUser *)user withContent:(NSString *)content withRating:(int)rating withCompletion:(void(^)(Review *review))completion {
    Review *newReview = [Review object];
    newReview.user = user;
    newReview.content = content;
    newReview.rating = rating;
    
    [newReview saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        completion(newReview);
    }];
}
@end
