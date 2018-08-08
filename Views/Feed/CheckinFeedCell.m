//
//  CheckinFeedCell.m
//  social-maps
//
//  Created by César Francisco Barraza on 8/1/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "CheckinFeedCell.h"
#import "ParseImageHelper.h"
#import "UIStylesHelper.h"

@interface CheckinFeedCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImage;
@property (weak, nonatomic) IBOutlet UIView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) CheckInEvent *event;
@end

@implementation CheckinFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // hide the cell
    [self.contentView setAlpha:0];
}

- (void)initUI {
    // set up content formatting
    NSString *content = [NSString stringWithFormat:@"%@ checked in to %@.", self.event.user.displayName, self.event.place.placeName];
    UIFont *font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13];
    
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedContent beginEditing];
    [attributedContent addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.event.user.displayName.length)];
    [attributedContent addAttribute:NSFontAttributeName value:font range:NSMakeRange(self.event.user.displayName.length + 15, self.event.place.placeName.length)];
    [attributedContent endEditing];
    
    // update UI
    [self.contentLabel setAttributedText:[attributedContent copy]];
    [ParseImageHelper setImageFromPFFile:self.event.user.profilePicture forImageView:self.profilePictureImage];
    self.timeLabel.text = [self.event getTimestamp];
    
    // set rounded image
    [UIStylesHelper addRoundedCornersToView:self.pictureView];
    [UIStylesHelper addRoundedCornersToView:self.profilePictureImage];
    [UIStylesHelper addShadowToView:self.pictureView];
    
    // fade into visibility
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentView setAlpha:1];
    }];
}

- (void)setEvent:(CheckInEvent *)event {
    _event = event;
    [self initUI];
}

@end
