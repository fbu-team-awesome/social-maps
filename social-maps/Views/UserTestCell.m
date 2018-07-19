//
//  UserTestCell.m
//  social-maps
//
//  Created by Bevin Benson on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "UserTestCell.h"

@implementation UserTestCell

- (void)setUser:(PFUser *)user {
    
    _user = user;
    
    self.usernameLabel.text = user.username;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)follow:(id)sender {
    
    
}



@end
