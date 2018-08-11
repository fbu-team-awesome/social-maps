//
//  NotificationCell.m
//  social-maps
//
//  Created by César Francisco Barraza on 8/6/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "NotificationCell.h"
#import "ParseImageHelper.h"
#import "UIStylesHelper.h"

@interface NotificationCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImage;
@property (weak, nonatomic) IBOutlet UIView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) FollowEvent *event;
@end

@implementation NotificationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView setAlpha:0];
}

- (void)initUI {
    NSString *content = [NSString stringWithFormat:@"%@ followed you.", self.event.user.displayName];
    UIFont *font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13];
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedContent beginEditing];
    [attributedContent addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.event.user.displayName.length)];
    [attributedContent endEditing];
    
    [self.contentLabel setAttributedText:[attributedContent copy]];
    [ParseImageHelper setImageFromPFFile:self.event.user.profilePicture forImageView:self.profilePictureImage];
     self.timeLabel.text = [self.event getTimestamp];
    
    // set rounded image
    [UIStylesHelper addRoundedCornersToView:self.pictureView];
    [UIStylesHelper addRoundedCornersToView:self.profilePictureImage];
    [UIStylesHelper addShadowToView:self.pictureView withOffset:CGSizeZero withRadius:2 withOpacity:0.16];
    
    // fade in
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentView setAlpha:1];
    }];
}

- (void)setEvent:(FollowEvent *)event {
    _event = event;
    [self initUI];
}
@end
