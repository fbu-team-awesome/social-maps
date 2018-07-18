//
//  Place.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Parse/Parse.h>
#import <GooglePlaces/GooglePlaces.h>
@interface Place : PFObject<PFSubclassing>
// Instance Properties //
@property (strong, nonatomic, nonnull) NSString* placeID;
@property (strong, nonatomic, nullable) NSString* placeName;

- (nonnull instancetype)initWithGMSPlace:(nonnull GMSPlace*)place;

+ (void)checkGMSPlaceExists:(GMSPlace*)place result:(void(^)(Place*))result;
@end

