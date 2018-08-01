//
//  FilterCheckboxCell.m
//  social-maps
//
//  Created by Bevin Benson on 7/31/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FilterCheckboxCell.h"
#import "MarkerManager.h"

@implementation FilterCheckboxCell

@synthesize selected;

- (void)configureCell {
    self.listName.text = self.list;
    
    if (self.selected) {
        [self.checkbox setSelected:YES];
    }
    else {
        [self.checkbox setSelected:NO];
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
    MarkerManager *markerManager = [MarkerManager shared];
    if (self.checkbox.selected) {
        [self.checkbox setSelected:NO];
        [markerManager.filters setValue:[NSNumber numberWithBool:NO] forKey:self.list];
    }
    else {
        [self.checkbox setSelected:YES];
        [markerManager.filters setValue:[NSNumber numberWithBool:YES] forKey:self.list];
    }
}

@end
