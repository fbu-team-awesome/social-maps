//
//  ReviewCell.h
//  social-maps
//
//  Created by Britney Phan on 8/7/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Review.h"

@interface ReviewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (strong, nonatomic) Review *review;

- (void)configureCell;

@end
