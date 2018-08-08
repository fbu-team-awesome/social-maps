//
//  CheckinFeedCell.m
//  social-maps
//
//  Created by César Francisco Barraza on 8/1/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "CheckinFeedCell.h"
#import "ParseImageHelper.h"

@interface CheckinFeedCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImage;
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
    NSString *content = [NSString stringWithFormat:@"%@ just checked-in at '%@'!", self.event.user.displayName, self.event.place.placeName];
    
    // update UI
    self.contentLabel.text = content;
    [ParseImageHelper setImageFromPFFile:self.event.user.profilePicture forImageView:self.profilePictureImage];
    self.timeLabel.text = [self.event getTimestamp];
    
    // set rounded image
    self.profilePictureImage.layer.cornerRadius = self.profilePictureImage.frame.size.width / 2;
    self.profilePictureImage.clipsToBounds = YES;
    
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
