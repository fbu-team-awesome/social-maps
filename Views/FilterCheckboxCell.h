//
//  FilterCheckboxCell.h
//  social-maps
//
//  Created by Bevin Benson on 7/31/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCheckboxCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *listName;
@property (weak, nonatomic) IBOutlet UIButton *checkbox;

@property (strong, nonatomic) NSString *list;
@property (nonatomic, getter=isSelected) BOOL selected;

- (void)configureCell;

@end
