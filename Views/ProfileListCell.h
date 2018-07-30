//
//  ProfileListCell.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

@import GoogleMaps;
@import GooglePlaces;
#import <UIKit/UIKit.h>

@interface ProfileListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *placeImage;

// Instance Methods //
- (void)setPlace:(GMSPlace*)place;
- (GMSPlace*)getPlace;
@end
