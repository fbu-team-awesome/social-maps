//
//  Relationships.m
//  social-maps
//
//  Created by Bevin Benson on 7/19/18.
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

+ (void)retrieveFollowersWithId:(NSString *)objectId WithCompletion: (void (^)(NSArray * followers))completion {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Relationships"];
    [query includeKey:@"followers"];
    [query getObjectInBackgroundWithId:objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        completion(object[@"followers"]);
    }];
}


+ (void)retrieveFollowingWithId:(NSString *)objectId WithCompletion: (void (^)(NSArray * followers))completion {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Relationships"];
    [query includeKey:@"following"];
    [query getObjectInBackgroundWithId:objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        completion(object[@"following"]);
    }];
}

- (void)addUserToFollowing:(PFUser*) user {
    
    if (![self.following containsObject:user]) {
        [self.following addObject:user];
        [self setObject:self.following forKey:@"following"];
    }
    [self saveInBackground];
}

- (void)addUserToFollowers:(PFUser*) user {
    
    if (![self.followers containsObject:user]) {
        [self.followers addObject:user];
        [self setObject:self.followers forKey:@"followers"];
    }
    [self saveInBackground];
}





@end
