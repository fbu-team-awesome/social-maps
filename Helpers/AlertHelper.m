//
//  AlertHelper.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/20/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "AlertHelper.h"

@implementation AlertHelper
+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message sender:(UIViewController*)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [sender presentViewController:alert animated:YES completion:nil];
}

+ (void)showPhotoAlertFrom:(UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>*)sender {
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


+ (void)showPhotoAlertWithoutCroppingFrom:(UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>*)sender {
    UIImagePickerController* picker = [UIImagePickerController new];
    picker.delegate = sender;
    
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
@end
