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


+ (void)retrieveReviewsWithIDs:(NSArray<NSString*>*)IDs withCompletion:(void(^)(NSArray<Review*>*))completion {
    NSMutableArray<Review*>* reviews = [NSMutableArray new];
    
    // if there are no IDs, return before
    if(IDs.count == 0)
    {
        completion([reviews copy]);
    }
    
    // loop through all IDs
    for(NSString* ID in IDs)
    {
        PFQuery* query = [PFQuery queryWithClassName:@"Review"];
        [query includeKey:@"user"];
        // query the ID
        [query getObjectInBackgroundWithId:ID
                                     block:^(PFObject * _Nullable object, NSError * _Nullable error)
         {
             if(object != nil)
             {
                 [reviews addObject:(Review*)object];
             }
             
             // if our users array's length is the same as the IDs, then we are done
             if(reviews.count == IDs.count)
             {
                 completion((NSArray*)reviews);
             }
         }
         ];
    }
}
@end
