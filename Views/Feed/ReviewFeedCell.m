//
//  ReviewFeedCell.m
//  social-maps
//
//  Created by César Francisco Barraza on 8/1/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "ReviewFeedCell.h"
#import "ParseImageHelper.h"
#import "UIStylesHelper.h"
#import "HCSStarRatingView.h"

@interface ReviewFeedCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImage;
@property (weak, nonatomic) IBOutlet UIView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (strong, nonatomic) ReviewAdditionEvent *event;
@end

@implementation ReviewFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // hide the cell
    [self.contentView setAlpha:0];
}

- (void)initUI {
    // set up content formatting
    NSString *content = [NSString stringWithFormat:@"%@ added a review for %@.", self.event.user.displayName, self.event.place.placeName];
    UIFont *font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13];
    
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedContent beginEditing];
    [attributedContent addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.event.user.displayName.length)];
    [attributedContent addAttribute:NSFontAttributeName value:font range:NSMakeRange(self.event.user.displayName.length + 20, self.event.place.placeName.length)];
    [attributedContent endEditing];
    
    // update UI
    [self.contentLabel setAttributedText:[attributedContent copy]];
    self.reviewLabel.text = self.event.review.content;
    [ParseImageHelper setImageFromPFFile:self.event.user.profilePicture forImageView:self.profilePictureImage];
    self.timeLabel.text = [self.event getTimestamp];
    
    // create stars view for rating
    HCSStarRatingView *rating = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
    rating.value = (CGFloat)self.event.review.rating;
    [rating setBackgroundColor:[UIColor clearColor]];
    [rating setEnabled:NO];
    rating.minimumValue = 0;
    rating.maximumValue = 5;
    rating.starBorderWidth= 0;
    rating.filledStarImage = [UIImage imageNamed:@"star_filled"] ;
    rating.emptyStarImage = [UIImage imageNamed:@"star_unfilled"];
    [self.ratingView addSubview:rating];
    
    // set rounded image
    [UIStylesHelper addRoundedCornersToView:self.pictureView];
    [UIStylesHelper addRoundedCornersToView:self.profilePictureImage];
    [UIStylesHelper addShadowToView:self.pictureView withOffset:CGSizeZero withRadius:2 withOpacity:0.16];

    // fade into visibility
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentView setAlpha:1];
    }];
}

- (void)setEvent:(ReviewAdditionEvent *)event {
    _event = event;
    [self initUI];
}

@end
