//
//  Helper.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "Helper.h"

@implementation Helper
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message sender:(UIViewController*)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [sender presentViewController:alert animated:YES completion:nil];
}

+ (void)showPhotoAlert:(UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>*)sender {
    UIImagePickerController* picker = [UIImagePickerController new];
    picker.delegate = sender;
    picker.allowsEditing = YES;
    
    // ask the user if they want to use camera or photo library
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Picture" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"Take Picture" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action)
                                   {
                                       // set source type and then show picker controller
                                       picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                       [sender presentViewController:picker animated:YES completion:nil];
                                   }
                                   ];
    UIAlertAction* galleryAction = [UIAlertAction actionWithTitle:@"Photo Gallery" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        // set source type and then show picker controller
                                        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                        [sender presentViewController:picker animated:YES completion:nil];
                                    }
                                    ];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    // add actions and present
    [alert addAction:cameraAction];
    [alert addAction:galleryAction];
    [alert addAction:cancelAction];
    [sender presentViewController:alert animated:YES completion:nil];
}

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
