//
//  UserFriends.m
//  social-maps
//
//  Created by Bevin Benson on 7/18/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "Relationships.h"

@implementation Relationships

@dynamic followers, following;

+ (NSString *)parseClassName {
    return @"Relationships";
}

+ (void)getUsersWithCompletion:(void (^)(NSArray * users))completion {
    
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        completion(objects);
        
    }];
    
}


@end
