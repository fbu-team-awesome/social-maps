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
@property (strong, nonatomic, nullable) NSString *content;
@property (nonatomic) int rating;
@end
