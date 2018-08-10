//
//  ReviewCell.m
//  social-maps
//
//  Created by Britney Phan on 8/7/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "ReviewCell.h"
#import "ParseImageHelper.h"
#import "PFUser+ExtendedUser.h"
#import "HCSStarRatingView.h"
#import "UIStylesHelper.h"
#import "DateTools.h"

@implementation ReviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void) configureCell {
    if (self.review) {
        [ParseImageHelper setImageFromPFFile:self.review.user.profilePicture forImageView:self.profilePicture];
        self.content.text = self.review.content;
        self.name.text = self.review.user.displayName;
        for (UIView *view in [self.rateView subviews])
        {
            [view removeFromSuperview];
        }
        HCSStarRatingView *ratingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(0, 0, 95, 13)];
        ratingView.minimumValue = 0;
        ratingView.maximumValue = 5;
        ratingView.starBorderWidth= 0;
        ratingView.filledStarImage = [UIImage imageNamed:@"star_filled"] ;
        ratingView.emptyStarImage = [UIImage imageNamed:@"star_unfilled"];
        ratingView.value = (CGFloat) self.review.rating;
        [ratingView setEnabled:NO];
        [self.rateView addSubview:ratingView];
        
        [UIStylesHelper addRoundedCornersToView:self.profilePicture];
        
        self.dateLabel.text = self.review.createdAt.timeAgoSinceNow;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
