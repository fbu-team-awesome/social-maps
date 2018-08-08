//
//  PhotoCell.h
//  social-maps
//
//  Created by Britney Phan on 8/2/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@protocol PhotoCellDelegate;

@interface PhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) Photo *photo;
@property (strong, nonatomic) id <PhotoCellDelegate> delegate;

- (void) configureCell;

@end

@protocol PhotoCellDelegate

- (void)didTapPhoto:(Photo *)photo;

@end
