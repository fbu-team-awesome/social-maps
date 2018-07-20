//
//  ParseImageHelper.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/20/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "ParseImageHelper.h"

@implementation ParseImageHelper
+ (void)setImageFromPFFile:(PFFile*)file forImageView:(UIImageView*)imageView {
    [file getDataInBackgroundWithBlock:
     ^(NSData* _Nullable data, NSError * _Nullable error)
     {
         if(error == nil)
         {
             [imageView setImage:[UIImage imageWithData:data]];
         }
         else
         {
             NSLog(@"Failed to convert PFFile to UIImage.");
         }
     }
     ];
}

+ (void)setImageFromPFFile:(PFFile*)file forButton:(UIButton*)button {
    [file getDataInBackgroundWithBlock:
     ^(NSData* _Nullable data, NSError * _Nullable error)
     {
         if(error == nil)
         {
             [button setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
         }
         else
         {
             NSLog(@"Failed to convert PFFile to UIImage.");
         }
     }
     ];
}

+ (PFFile*)getPFFileFromImage:(UIImage*)image {
    if(image == nil)
    {
        return nil;
    }
    
    NSData* imageData = UIImagePNGRepresentation(image);
    if (imageData == nil)
    {
        return nil;
    }
    
    // if we get here, image is fine
    return [PFFile fileWithName:@"image.png" data:imageData];
}
@end
