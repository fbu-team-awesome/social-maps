//
//  Relationships.h
//  social-maps
//
//  Created by Bevin Benson on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Relationships : PFObject<PFSubclassing>

@property (strong, nonatomic, nonnull) NSMutableArray *following;
@property (strong, nonatomic, nonnull) NSMutableArray *followers;

+ (void)getUsersWithCompletion:(void (^_Nonnull)(NSArray *users))completion;

+ (void)retrieveFollowersWithId:(NSString *)objectId WithCompletion: (void (^)(NSArray * followers))completion;

+ (void)retrieveFollowingWithId:(NSString *)objectId WithCompletion: (void (^)(NSArray * following))completion;

- (void)addUserToFollowing:(PFUser*) user;

- (void)addUserToFollowers:(PFUser*) user;

@end
