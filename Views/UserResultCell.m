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

@implementation UserResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configureCell {
    self.nameLabel.text = self.user.displayName;
    self.cityLabel.text = self.user.hometown;
    if (self.user.profilePicture == nil) {
        self.profilePicture.image = nil;
    } else {
        [ParseImageHelper setImageFromPFFile:self.user.profilePicture forImageView:self.profilePicture];
    }
    self.usernameLabel.text = self.user.username;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)didTapFollow:(id)sender {
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser follow:self.user];
    [NCHelper notify:NTNewFollow object:self.user];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"NewFollowNotification" object:self.user];
}

@end
