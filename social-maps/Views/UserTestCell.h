//
//  UserTestCell.h
//  social-maps
//
//  Created by Bevin Benson on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFUser+ExtendedUser.h"

@interface UserTestCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (strong, nonatomic) PFUser *user;

@end
