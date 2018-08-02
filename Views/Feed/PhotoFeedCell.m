//
//  PhotoFeedCell.m
//  social-maps
//
//  Created by César Francisco Barraza on 8/1/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "PhotoFeedCell.h"
#import "ParseImageHelper.h"

@interface PhotoFeedCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImage;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (strong, nonatomic) PhotoAdditionEvent *event;
@end

@implementation PhotoFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)initUI {
    // set up content formatting
    NSString *content = [NSString stringWithFormat:@"%@ added a picture for '%@'.", self.event.user.displayName, self.event.place.placeName];
    
    // update UI
    self.contentLabel.text = content;
    [ParseImageHelper setImageFromPFFile:self.event.user.profilePicture forImageView:self.profilePictureImage];
    [ParseImageHelper setImageFromPFFile:self.event.photo forImageView:self.photoImage];
}

- (void)setEvent:(PhotoAdditionEvent *)event {
    _event = event;
    [event queryInfoWithCompletion:^{
        if(event.user.isDataAvailable && event.place.isDataAvailable)
        {
            [self initUI];
        }
    }];
}

@end
