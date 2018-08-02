//
//  AlertHelper.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/20/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertHelper : NSObject
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message sender:(UIViewController*)sender;
+ (void)showPhotoAlertFrom:(UIViewController*)sender;
+ (void)showPhotoAlertWithoutCroppingFrom:(UIViewController *)sender;

@end
