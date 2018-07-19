//
//  ProfileViewController.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/17/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFUser+ExtendedUser.h"

@interface ProfileViewController : UIViewController
// Instance Methods //
- (void)setUser:(PFUser*)user;
@end
