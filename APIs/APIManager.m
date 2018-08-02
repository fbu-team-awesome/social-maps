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
static const NSUInteger kQuerySize = 10;

@interface APIManager()

@property (strong, nonatomic) NSDate *lastQueryDate;
@end

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

- (void)getNextGMSPlacesBatch:(void(^)(NSArray<GMSPlace *> *places))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
    query.limit = kQuerySize;
    [query orderByDescending:@"createdAt"];
    if (self.lastQueryDate != nil) {
        [query whereKey:@"createdAt" lessThan:self.lastQueryDate];
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        Place *lastPlace = [objects lastObject];
        self.lastQueryDate = lastPlace.createdAt;
        if (error == nil && objects != nil) {
            NSArray<Place *> *orderedObjects = [NSArray arrayWithArray:objects];
            
            Place *placeHolder = [[Place alloc] init];
            NSMutableArray *places = [NSMutableArray arrayWithCapacity:kQuerySize];
            for (int i = 0; i < orderedObjects.count; i++) {
                [places addObject:placeHolder];
            }
            
            __block NSUInteger count = 0;
            for (int i = 0; i < orderedObjects.count; ++i) {
                Place *myPlace = orderedObjects[i];
                
                // convert each Place to a GMSPlace
                [self GMSPlaceFromPlace:myPlace withCompletion:^(GMSPlace *place) {
                    [places replaceObjectAtIndex:i withObject:place];
                    count++;
                    if (count == objects.count) {
                        [places removeObjectIdenticalTo:placeHolder];
                        completion(places);
                    }
                }];
            }
        } else {
            NSLog(@"Error getting all places");
        }
    }];
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
