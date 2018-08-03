//
//  PhotoCell.h
//  social-maps
//
//  Created by Britney Phan on 8/2/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface PhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) Photo *photo;
- (void) configureCell;

@end
