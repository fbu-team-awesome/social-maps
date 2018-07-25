//
//  APIManager.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "APIManager.h"

static NSString* GOOGLE_API_KEY = @"AIzaSyDPNMeUT45545fwU_98uWqn0yNfgbtr1ZE";
static NSString* PARSE_APP_ID = @"ID_VENTUREAWESOMEAPP";
static NSString* PARSE_MASTER_KEY = @"KEY_VENTUREAWESOMEAPP";
static NSString* PARSE_SERVER_URL = @"http://ventureawesomeapp.herokuapp.com/parse";

@implementation APIManager
+ (instancetype)shared {
    static APIManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (void)setupParse {
    ParseClientConfiguration* config = [ParseClientConfiguration configurationWithBlock:
                                        ^(id<ParseMutableClientConfiguration>  _Nonnull configuration)
                                        {
                                            configuration.applicationId = PARSE_APP_ID;
                                            configuration.clientKey = PARSE_MASTER_KEY;
                                            configuration.server = PARSE_SERVER_URL;
                                        }
                                        ];
    [Parse initializeWithConfiguration:config];
}

- (void)setupGoogle {
    [GMSPlacesClient provideAPIKey:GOOGLE_API_KEY];
    [GMSServices provideAPIKey:GOOGLE_API_KEY];
}

- (void)GMSPlaceFromPlace:(Place*)place withCompletion:(void(^)(GMSPlace* place))completion {
    GMSPlacesClient* placesClient = [GMSPlacesClient sharedClient];
    
    // send request for place using ID
    [placesClient lookUpPlaceID:place.placeID
                  callback:^(GMSPlace * _Nullable result, NSError * _Nullable error)
                  {
                      if(error == nil)
                      {
                          if(result != nil)
                          {
                              completion(result);
                          }
                      }
                      else
                      {
                          NSLog(@"Error looking up place with ID '%@':%@", place.placeID, error.localizedDescription);
                      }
                  }
     ];
}

- (void)GMSPlaceFromID:(NSString*)placeID withCompletion:(void(^)(GMSPlace* place))completion {
    GMSPlacesClient* placesClient = [GMSPlacesClient sharedClient];
    
    // send request for place using ID
    [placesClient lookUpPlaceID:placeID
                  callback:^(GMSPlace * _Nullable result, NSError * _Nullable error)
                  {
                      if(error == nil)
                      {
                          if(result != nil)
                          {
                              completion(result);
                          }
                      }
                      else
                      {
                          NSLog(@"Error looking up place with ID '%@':%@", placeID, error.localizedDescription);
                      }
                  }
     ];
}

- (void)getAllGMSPlaces:(void(^)(NSArray<GMSPlace*>* places))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil && objects != nil)  {
            // convert array of Place objects to GMSPlace objects
            NSMutableArray<GMSPlace*>* array = [NSMutableArray new];
            for (Place *myPlace in objects) {
                [self GMSPlaceFromPlace:myPlace withCompletion:^(GMSPlace *place) {
                    [array addObject:place];
                    
                    if(array.count == objects.count)
                    {
                        completion((NSArray*)array);
                    }
                }];
            }
        } else {
            NSLog(@"Error getting all places");
        }
    }];
}

- (void)getNextTenGMSPlaces:(NSString *)lastPlaceID :(void(^)(NSArray<GMSPlace *> *places))completion {
    
    [self getTimeOfPlaceCreation:lastPlaceID withCompletion:^(NSDate *date) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"Place"];
        query.limit = 10;
        [query orderByDescending:@"createdAt"];
        
        if (date) {
            [query whereKey:@"createdAt" greaterThan:date];
        }
        
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error == nil && objects != nil) {
                
                NSMutableArray<Place *> *orderedObjects = [NSMutableArray arrayWithCapacity:10];
                for (Place *myPlace in objects) {
                    [orderedObjects addObject:myPlace];
                }
                
                Place *placeHolder = [[Place alloc] init];
                // convert array of Place objects to GMSPlace objects
                NSMutableArray *places = [NSMutableArray arrayWithCapacity:10];
                for (int i = 0; i < orderedObjects.count; i++) {
                    [places addObject:placeHolder];
                }
                __block NSNumber *count;
                count = [NSNumber numberWithInteger:0];
                for (Place *myPlace in orderedObjects) {
                    [self GMSPlaceFromPlace:myPlace withCompletion:^(GMSPlace *place) {
                        [places replaceObjectAtIndex:[orderedObjects indexOfObject:myPlace] withObject:place];
                        count = [NSNumber numberWithInt:[count intValue] + 1];

                        if ([count isEqual:[NSNumber numberWithInteger:places.count - 1]]) {
                            
                            completion(places);
                        }
                    }];
                }
                
            } else {
                NSLog(@"Error getting all places");
            }
        }];
    }];
}

// block or return????
- (void)getTimeOfPlaceCreation:(NSString *)placeId withCompletion:(void(^)(NSDate*))completion {
    
    if (placeId) {
        PFQuery *query = [PFQuery queryWithClassName:@"Place"];
        [query whereKey:@"placeID" equalTo:placeId];
        [query includeKey:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            Place *lastPlace = objects[0];
            NSDate *timeCreatedAt = lastPlace.createdAt;
            // timeCreatedAt = [timeCreatedAt substringToIndex:19];
            completion(timeCreatedAt);
        }];
    }
    else {
        completion(nil);
    }
}
            
// gets the GMSPlacePhotoMetadata for the first ten images
- (void)getPhotoMetadata:(NSString *)placeID :(void(^)(NSArray<GMSPlacePhotoMetadata *> *photoMetadata))completion {
    [[GMSPlacesClient sharedClient] lookUpPhotosForPlaceID:placeID callback:^(GMSPlacePhotoMetadataList *_Nullable photos, NSError *_Nullable error) {
        
        if (error) {
            NSLog(@"Error: %@", [error description]);
        }
        else {
            if (photos.results.count > 0) {
                
                if (photos.results.count > 10) {
                    completion([photos.results subarrayWithRange:NSMakeRange(0, 9)]);
                }
                else {
                    completion(photos.results);
                }
            }
        }
    }];
}
            
- (void)getAllUsers:(void(^)(NSArray<PFUser*>* users))completion {
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error == nil && objects != nil) {
            completion(objects);
        } else {
            NSLog(@"Error getting all users");
        }
    }];
}
@end
