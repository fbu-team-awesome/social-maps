//
//  UserFriends.m
//  social-maps
//
//  Created by Bevin Benson on 7/18/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "UserFriends.h"

@implementation UserFriends

@dynamic followers, following;

+ (NSString *)parseClassName {
    return @"UserFriends";
}

+ (NSArray *)getUsers {
    
    PFQuery *query = [PFUser query];
    
    NSArray *users = [query findObjects];
    
    return users;
}


@end
