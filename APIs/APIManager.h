//
//  APIManager.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

@import GoogleMaps;
@import GooglePlaces;

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Place.h"

@interface APIManager : NSObject
// Singleton Accessor //
+ (instancetype)shared;

// Instance Methods //
- (void)setupParse;
- (void)setupGoogle;
- (void)GMSPlaceFromPlace:(Place*)place withCompletion:(void(^)(GMSPlace* place))completion;
- (void)GMSPlaceFromID:(NSString*)placeID withCompletion:(void(^)(GMSPlace* place))completion;
- (void)getAllGMSPlaces:(void(^)(NSArray<GMSPlace*>* places))completion;
- (void)getAllUsers:(void(^)(NSArray<PFUser*>* users))completion;
- (void)getPhotoMetadata:(NSString *)placeID :(void(^)(NSArray<GMSPlacePhotoMetadata *> *photoMetadata))completion;
- (void)getNextGMSPlacesBatch:(void(^)(NSArray<GMSPlace *> *places))completion;

@end
