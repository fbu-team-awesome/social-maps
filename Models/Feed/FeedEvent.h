//
//  FeedEvent.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Parse/Parse.h>
#import "PFUser+ExtendedUser.h"
#import "Place.h"

@interface FeedEvent : PFObject <PFSubclassing>
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) Place *place;
@end
