//
//  ParseImageHelper.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/20/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ParseImageHelper : NSObject
+ (void)setImageFromPFFile:(PFFile*)file forImageView:(UIImageView*)imageView;
+ (void)setImageFromPFFile:(PFFile*)file forButton:(UIButton*)button;
+ (PFFile*)getPFFileFromImage:(UIImage*)image;
@end
