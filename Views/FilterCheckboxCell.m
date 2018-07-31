//
//  FilterCheckboxCell.m
//  social-maps
//
//  Created by Bevin Benson on 7/31/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FilterCheckboxCell.h"

@implementation FilterCheckboxCell

- (void)configureCell {
    
    self.listName.text = self.list;
    if ([self.selected boolValue]) {
        [self.checkbox setSelected:NO];
    }
    else {
        [self.checkbox setSelected:YES];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)checkboxTapped:(id)sender {
    if (self.checkbox.selected) {
        [self.checkbox setSelected:NO];
    }
    else {
        [self.checkbox setSelected:YES];
    }
}

@end
