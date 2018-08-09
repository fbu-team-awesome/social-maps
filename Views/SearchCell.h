//
//  SearchCell.h
//  social-maps
//
//  Created by Britney Phan on 7/18/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>
#import "APIManager.h"
@protocol SearchCellDelegate;

@interface SearchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) GMSPlace *place;
@property (strong, nonatomic) GMSAutocompletePrediction *prediction;
@property (strong,nonatomic) id<SearchCellDelegate> delegate;
- (void)configureCell;
@end

@protocol SearchCellDelegate
- (void)didAddToFavorites:(GMSPlace *)place;
- (void)didAddToWishlist:(GMSPlace *)place;
@end
