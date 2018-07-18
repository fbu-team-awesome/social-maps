//
//  DetailsViewController.h
//  social-maps
//
//  Created by Britney Phan on 7/17/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

@import GoogleMaps;
@import GooglePlaces;
#import <UIKit/UIKit.h>
#import "PFUser+ExtendedUser.h"

@interface DetailsViewController : UIViewController
- (void)setPlace:(GMSPlace*)place;
@end
