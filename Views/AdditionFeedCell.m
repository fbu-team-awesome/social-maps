//
//  AdditionFeedCell.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "AdditionFeedCell.h"
#import "ParseImageHelper.h"

@interface AdditionFeedCell ()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImage;
@property (strong, nonatomic) ListAdditionEvent *event;
@end

@implementation AdditionFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)initUI {
    // set up content formatting
    NSString *listType = nil;
    if(self.event.listType == LTFavorite)
    {
        listType = @"favorites";
    }
    else
    {
        listType = @"wishlist";
    }
    NSString *content = [NSString stringWithFormat:@"%@ just added '%@' to their %@!", self.event.user.displayName, self.event.place.placeName, listType];
    
    // update UI
    self.contentLabel.text = content;
    [ParseImageHelper setImageFromPFFile:self.event.user.profilePicture forImageView:self.profilePictureImage];
}

- (void)setEvent:(ListAdditionEvent *)event {
    _event = event;
    [self.event queryInfoWithCompletion:^{
        [self initUI];
    }];
}
@end
