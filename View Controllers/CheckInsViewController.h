//
//  CheckInsViewController.h
//  social-maps
//
//  Created by Britney Phan on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CheckInsViewController : UIViewController

@property (strong, nonatomic) NSArray <PFUser*>* users;

@end
