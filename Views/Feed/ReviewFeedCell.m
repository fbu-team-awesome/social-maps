//
//  ReviewFeedCell.m
//  social-maps
//
//  Created by César Francisco Barraza on 8/1/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "ReviewFeedCell.h"
#import "ParseImageHelper.h"

@interface ReviewFeedCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImage;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;
@property (strong, nonatomic) ReviewAdditionEvent *event;
@end

@implementation ReviewFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // hide the cell
    [self.contentView setAlpha:0];}

- (void)initUI {
    // set up content formatting
    NSString *content = [NSString stringWithFormat:@"%@ added a picture for '%@'.", self.event.user.displayName, self.event.place.placeName];
    
    // update UI
    self.contentLabel.text = content;
    self.ratingLabel.text = [NSString stringWithFormat:@"%i/5", self.event.review.rating];
    self.reviewLabel.text = self.event.review.content;
    [ParseImageHelper setImageFromPFFile:self.event.user.profilePicture forImageView:self.profilePictureImage];
    
    // set rounded image
    self.profilePictureImage.layer.cornerRadius = self.profilePictureImage.frame.size.width / 2;
    self.profilePictureImage.clipsToBounds = YES;
    
    // fade into visibility
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentView setAlpha:1];
    }];
}

- (void)setEvent:(ReviewAdditionEvent *)event {
    _event = event;
    [event queryInfoWithCompletion:^{
       if(event.user.isDataAvailable && event.place.isDataAvailable && event.review.isDataAvailable)
       {
           [self initUI];
       }
    }];
}

@end
