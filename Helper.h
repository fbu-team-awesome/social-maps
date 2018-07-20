//
//  Helper.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface Helper : NSObject
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message sender:(UIViewController*)sender;
+ (void)showPhotoAlertFrom:(UIViewController*)sender;

+ (UIImage*)resizeImage:(UIImage*)image withSize:(CGSize)size;

+ (void)setImageFromPFFile:(PFFile*)file forImageView:(UIImageView*)imageView;
+ (void)setImageFromPFFile:(PFFile*)file forButton:(UIButton*)button;
+ (PFFile*)getPFFileFromImage:(UIImage*)image;
@end
