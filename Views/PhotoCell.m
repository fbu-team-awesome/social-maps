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
    }
}

@end
