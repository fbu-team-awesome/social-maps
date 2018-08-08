//
//  AdditionFeedCell.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "AdditionFeedCell.h"
#import "ParseImageHelper.h"
#import "UIStylesHelper.h"

@interface AdditionFeedCell ()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *pictureView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImage;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) ListAdditionEvent *event;
@end

@implementation AdditionFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // hide the cell
    [self.contentView setAlpha:0];
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
    NSString *content = [NSString stringWithFormat:@"%@ added %@ to their %@.", self.event.user.displayName, self.event.place.placeName, listType];
    UIFont *font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13];
    
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedContent beginEditing];
    [attributedContent addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.event.user.displayName.length)];
    [attributedContent addAttribute:NSFontAttributeName value:font range:NSMakeRange(self.event.user.displayName.length + 7, self.event.place.placeName.length)];
    [attributedContent endEditing];
    
    // update UI
    [self.contentLabel setAttributedText:[attributedContent copy]];
    [ParseImageHelper setImageFromPFFile:self.event.user.profilePicture forImageView:self.profilePictureImage];
    self.timeLabel.text = [self.event getTimpestamp];
    
    // set rounded image
    [UIStylesHelper addRoundedCornersToView:self.pictureView];
    [UIStylesHelper addRoundedCornersToView:self.profilePictureImage];
    [UIStylesHelper addShadowToView:self.pictureView];
    
    // fade into visibility
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentView setAlpha:1];
    }];
}

- (void)setEvent:(ListAdditionEvent *)event {
    _event = event;
    [self initUI];
}
@end
