//
//  NotificationCell.m
//  social-maps
//
//  Created by César Francisco Barraza on 8/6/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "NotificationCell.h"
#import "ParseImageHelper.h"

@interface NotificationCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImage;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) FollowEvent *event;
@end

@implementation NotificationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView setAlpha:0];
}

- (void)initUI {
    self.contentLabel.text = [NSString stringWithFormat:@"%@ followed you.", self.event.user.displayName];
    [ParseImageHelper setImageFromPFFile:self.event.user.profilePicture forImageView:self.profilePictureImage];
    
    // fade in
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentView setAlpha:1];
    }];
}

- (void)setEvent:(FollowEvent *)event {
    _event = event;
    [event queryInfoWithCompletion:^{
       if(event.user.isDataAvailable)
       {
           [self initUI];
       }
    }];
}
@end
