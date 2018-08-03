//
//  ImageHelper.h
//  social-maps
//
//  Created by César Francisco Barraza on 7/20/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageHelper : NSObject
+ (UIImage*)resizeImage:(UIImage*)image withSize:(CGSize)size;
+ (UIImage*)resizeImageForParse:(UIImage *)image;

@end
