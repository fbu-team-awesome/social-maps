//
//  Review.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Parse/Parse.h>

@interface Review : PFObject <PFSubclassing>
@property (strong, nonatomic, nonnull) PFUser *user;
@property (strong, nonatomic, nonnull) NSString *content;
@property (nonatomic) int rating;

+ (void)reviewWithUser:(nonnull PFUser *)user withContent:(nonnull NSString *)content withRating:(int)rating withCompletion:(void(^_Nullable)(Review * _Nonnull review))completion;
+ (void)retrieveReviewsWithIDs:(NSArray<NSString*>*_Nonnull)IDs withCompletion:(void(^_Nullable)(NSArray<Review*>*))completion;

@end
