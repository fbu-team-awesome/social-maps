//
//  UserFriends.h
//  social-maps
//
//  Created by Bevin Benson on 7/18/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface UserFriends : PFObject

@property (strong, nonatomic, nonnull) NSMutableArray *following;
@property (strong, nonatomic, nonnull) NSMutableArray *followers;

+ (NSArray *_Nullable)getUsers;

@end
