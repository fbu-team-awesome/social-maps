//
//  ListViewCell.m
//  social-maps
//
//  Created by Bevin Benson on 7/17/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "ListViewCell.h"

@implementation ListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setPlace:(Place *)place {
    
    _place = place;
    
    self.titleLabel.text = place.placeName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
