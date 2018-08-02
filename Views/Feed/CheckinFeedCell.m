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
@property (strong, nonatomic) CheckInEvent *event;
@end

@implementation CheckinFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)initUI {
    // set up content formatting
    NSString *content = [NSString stringWithFormat:@"%@ just checked-in at '%@'!", self.event.user.displayName, self.event.place.placeName];
    
    // update UI
    self.contentLabel.text = content;
    [ParseImageHelper setImageFromPFFile:self.event.user.profilePicture forImageView:self.profilePictureImage];
}

- (void)setEvent:(CheckInEvent *)event {
    _event = event;
    [event queryInfoWithCompletion:^{
       if(event.user.isDataAvailable && event.place.isDataAvailable)
       {
           [self initUI];
       }
    }];
}

@end
