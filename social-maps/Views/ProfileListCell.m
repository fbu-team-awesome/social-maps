//
//  ProfileListCell.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "ProfileListCell.h"

@interface ProfileListCell ()
// Outlet Definitions //
@property (weak, nonatomic) IBOutlet UIImageView *pictureImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

// Instance Properties //
@property (strong, nonatomic) GMSPlace* place;

@end

@implementation ProfileListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUI {
    // todo image
    self.nameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
}

- (void)setPlace:(GMSPlace*)place {
    _place = place;
    [self updateUI];
}

- (GMSPlace*)getPlace {
    return _place;
}
@end
