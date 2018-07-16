//
//  APIManager.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "APIManager.h"

static NSString* GOOGLE_API_KEY = @"AIzaSyD85wTf96wx5cH8LoptbeSpUk3dVROHgyg";
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
@end
