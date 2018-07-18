//
//  SearchCell.h
//  social-maps
//
//  Created by Britney Phan on 7/18/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>

@interface SearchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) GMSAutocompletePrediction *prediction;
- (void) configureCell;
@end
