//
//  RelationshipListCell.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFUser+ExtendedUser.h"
#import "ParseImageHelper.h"

@interface RelationshipListCell : UITableViewCell
// Instance Methods //
- (void)setUser:(PFUser*)user;
- (PFUser*)getUser;
@end
