//
//  Place.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "PFObject.h"

@interface Place : PFObject<PFSubclassing>
// Instance Properties //
@property (strong, nonatomic) NSString* placeID;
@end
