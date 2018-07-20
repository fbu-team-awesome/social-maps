//
//  RelationshipListCell.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "RelationshipListCell.h"

@interface RelationshipListCell ()
// Outlet Definitions //
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hometownLabel;

// Instance Properties //
@property (strong, nonatomic) PFUser* user;
@end

@implementation RelationshipListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
   // [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUI {
    [ParseImageHelper setImageFromPFFile:self.user.profilePicture forImageView:self.profileImage];
    self.nameLabel.text = self.user.displayName;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", self.user.username];
    self.hometownLabel.text = self.user.hometown;
}

- (void)setUser:(PFUser*)user {
    _user = user;
    [self updateUI];
}
@end
