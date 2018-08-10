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
+ (void)addRoundedCornersToView:(UIView *)view;
+ (void)addShadowToView:(UIView *)view;
+ (void)addShadowToView:(UIView *)view withOffset:(CGSize)offset withRadius:(CGFloat)radius withOpacity:(float)opacity;
+ (void)addGradientToView:(UIView *)view;
+ (void)setCustomNavBarStyle:(UINavigationController *)navigationController;
+ (void)animateTapOnView:(UIView *)view;
@end
