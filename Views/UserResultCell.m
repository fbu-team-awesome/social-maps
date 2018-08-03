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
    self.usernameLabel.text = self.user.username;
    [self setProfilePic];
}

- (void)setProfilePic {
    if (self.user.profilePicture == nil) {
        self.profilePicture.image = nil;
    } else {
        [ParseImageHelper setImageFromPFFile:self.user.profilePicture forImageView:self.profilePicture];
    }
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width/2;
    self.profilePicture.clipsToBounds = YES;
    self.profilePicture.layer.borderWidth = 2.0f;
    self.profilePicture.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)didTapFollow:(id)sender {
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser follow:self.user];
    [NCHelper notify:NTNewFollow object:self.user];
}

@end
