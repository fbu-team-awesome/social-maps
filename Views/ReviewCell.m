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

@implementation ReviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void) configureCell {
    if (self.review) {
        [ParseImageHelper setImageFromPFFile:self.review.user.profilePicture forImageView:self.profilePicture];
        self.content.text = self.review.content;
        self.name.text = self.review.user.displayName;
        HCSStarRatingView *ratingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
        ratingView.value = (CGFloat) self.review.rating;
        [ratingView setEnabled:NO];
        [self.rateView addSubview:ratingView];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
