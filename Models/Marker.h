//
//  Marker.h
//  social-maps
//
//  Created by Bevin Benson on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlaces/GooglePlaces.h>

@interface Marker : NSObject

- (instancetype)initWithGMSPlace:(GMSPlace *)place;

@property (strong, nonatomic) GMSPlace *place;

@end
