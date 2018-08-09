//
//  PhotoCell.m
//  social-maps
//
//  Created by Britney Phan on 8/2/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "PhotoCell.h"
#import "ParseImageHelper.h"

@implementation PhotoCell

- (void) configureCell {
    if (self.photo) {
        [ParseImageHelper setImageFromPFFile:self.photo.file forImageView:self.photoView];
        self.photoView.layer.cornerRadius = 5;
        self.photoView.clipsToBounds = YES;
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    
    [self.photoView setUserInteractionEnabled:YES];
    [self.photoView addGestureRecognizer:tapGestureRecognizer];
}

- (IBAction)didTap:(UITapGestureRecognizer *)sender {
    if (self.delegate != nil) {
        [self.delegate didTapPhoto:self.photo];
    } else {
        NSLog(@"Delegate is nil");
    }
}


@end
