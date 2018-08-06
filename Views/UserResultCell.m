//
//  UserResultCell.m
//  social-maps
//
//  Created by Britney Phan on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "UserResultCell.h"
#import "ParseImageHelper.h"
#import "NCHelper.h"

@interface UserResultCell ()
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIView *profilePictureView;

@end

@implementation UserResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // set button style
    self.followButton.layer.cornerRadius = self.followButton.frame.size.height / 2 - 1;
    self.followButton.clipsToBounds = YES;
    self.followButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.followButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.followButton.layer.shadowRadius = 5;
    self.followButton.layer.shadowOpacity = 0.2;
    self.followButton.layer.masksToBounds = NO;
    
    // set invisible at first
    [self.contentView setAlpha:0];
}

- (void)configureCell {
    self.nameLabel.text = self.user.displayName;
    self.cityLabel.text = self.user.hometown;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", self.user.username];
    [self setProfilePic];

    [[PFUser currentUser] retrieveRelationshipWithCompletion:^(Relationships *relationship) {
        if([relationship.following containsObject:self.user.objectId])
        {
            [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
            self.followButton.layer.borderWidth = 1;
            self.followButton.layer.borderColor = [UIColor colorNamed:@"VTR_Main"].CGColor;
            [self.followButton setTitleColor:[UIColor colorNamed:@"VTR_Main"] forState:UIControlStateNormal];
            [self.followButton setBackgroundColor:[UIColor colorNamed:@"VTR_Background"]];
        }
        // fade in
        [UIView animateWithDuration:0.3 animations:^{
            [self.contentView setAlpha:1];
        }];
    }];
}

- (void)setProfilePic {
    if (self.user.profilePicture == nil) {
        self.profilePicture.image = nil;
    } else {
        [ParseImageHelper setImageFromPFFile:self.user.profilePicture forImageView:self.profilePicture];
    }
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width/2;
    self.profilePicture.clipsToBounds = YES;
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width/2;
    self.profilePictureView.clipsToBounds = YES;
    self.profilePictureView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.profilePictureView.layer.shadowOffset = CGSizeZero;
    self.profilePictureView.layer.shadowRadius = 5;
    self.profilePictureView.layer.shadowOpacity = 0.2;
    self.profilePictureView.layer.masksToBounds = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)toggleFollowButton {
    if([self.followButton.titleLabel.text isEqualToString:@"Follow"])
    {
        [UIView animateWithDuration:0.2 animations:^{
            [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
            self.followButton.layer.borderWidth = 1;
            self.followButton.layer.borderColor = [UIColor colorNamed:@"VTR_Main"].CGColor;
            [self.followButton setTitleColor:[UIColor colorNamed:@"VTR_Main"] forState:UIControlStateNormal];
            [self.followButton setBackgroundColor:[UIColor colorNamed:@"VTR_Background"]];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
            self.followButton.layer.borderWidth = 0;
            self.followButton.layer.borderColor = [UIColor clearColor].CGColor;
            [self.followButton setTitleColor:[UIColor colorNamed:@"VTR_Background"] forState:UIControlStateNormal];
            [self.followButton setBackgroundColor:[UIColor colorNamed:@"VTR_Main"]];
        }];
    }
}

- (IBAction)didTapFollow:(id)sender {
    if([self.followButton.titleLabel.text isEqualToString:@"Follow"])
    {
        [[PFUser currentUser] follow:self.user];
    }
    else
    {
        [[PFUser currentUser] unfollow:self.user];
    }
    [self toggleFollowButton];
    [[UIImpactFeedbackGenerator new] impactOccurred];
}

@end
