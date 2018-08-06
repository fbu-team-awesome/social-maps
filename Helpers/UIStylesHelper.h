//
//  UIStylesHelper.h
//  social-maps
//
//  Created by César Francisco Barraza on 8/6/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIStylesHelper : NSObject
+ (void)setRoundedCornersToView:(UIView *)view;
+ (void)setShadowToView:(UIView *)view;
+ (void)setShadowToView:(UIView *)view withOffset:(CGSize)offset withRadius:(CGFloat)radius withOpacity:(float)opacity;
+ (void)setCustomNavBarStyle:(UINavigationController *)navigationController;
@end
