//
//  ImageHelper.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/20/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "ImageHelper.h"

@implementation ImageHelper
// resizeImage: method from https://hackmd.io/s/B1UKigxm7
+ (UIImage*)resizeImage:(UIImage*)image withSize:(CGSize)size {
    UIImageView* resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage*)resizeImageForParse:(UIImage *)image{
    //get aspect ratio of image
    CGFloat aspectRatio = image.size.width / image.size.height;
    
    CGSize size;
    UIImageView* resizeImageView;
    
    if(aspectRatio >= 1) { //if image is wider than tall, max value is width
        CGFloat imageHeight = 1/aspectRatio * 1024;
        resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, imageHeight)];
        size = CGSizeMake(1024, imageHeight);
    } else {
        CGFloat imageWidth = aspectRatio * 1024;
        resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, 1024)];
        size = CGSizeMake(imageWidth, 1024);
    }
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
