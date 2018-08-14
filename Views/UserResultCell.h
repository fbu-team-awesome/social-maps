//
//  UserResultCell.h
//  social-maps
//
//  Created by Britney Phan on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PFUser+ExtendedUser.h"

@interface UserResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) PFUser *user;

- (void)configureCell;
- (void)checkIfFollowing;
@end
