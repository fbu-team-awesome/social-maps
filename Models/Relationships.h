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

@property (strong, nonatomic, nonnull) NSArray<NSString *> *following;
@property (strong, nonatomic, nonnull) NSArray<NSString *> *followers;

// Class Methods //
+ (void)getUsersWithCompletion:(void (^_Nullable)(NSArray* _Nullable users))completion;
+ (void)retrieveFollowersWithId:(nonnull NSString*)objectId WithCompletion: (void (^_Nullable)(NSArray* _Nullable followers))completion;
+ (void)retrieveFollowingWithId:(nonnull NSString*)objectId WithCompletion: (void (^_Nullable)(NSArray* _Nullable following))completion;

// Instance Methods //
- (void)addUserIdToFollowing:(nonnull NSString*) userId;
- (void)addUserIdToFollowers:(nonnull NSString*) userId;
- (void)removeUserIDFromFollowing:(nonnull NSString*)userID;
- (void)removeUserIDFromFollowers:(nonnull NSString*)userID;
@end
