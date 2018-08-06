//
//  UIStylesHelper.m
//  social-maps
//
//  Created by César Francisco Barraza on 8/6/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "UIStylesHelper.h"

@implementation UIStylesHelper
+ (void)setRoundedCornersToView:(UIView *)view {
    CGFloat width = view.frame.size.width, height = view.frame.size.height;
    if(width > height)
    {
        view.layer.cornerRadius = height / 2;
    }
    else if(width <= height)
    {
        view.layer.cornerRadius = width / 2;
    }
    view.clipsToBounds = YES;
}

+ (void)setShadowToView:(UIView *)view {
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.shadowRadius = 5;
    view.layer.shadowOpacity = 0.2;
    view.layer.masksToBounds = NO;
}

+ (void)setShadowToView:(UIView *)view withOffset:(CGSize)offset withRadius:(CGFloat)radius withOpacity:(float)opacity {
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = offset;
    view.layer.shadowRadius = radius;
    view.layer.shadowOpacity = opacity;
    view.layer.masksToBounds = NO;
}

+ (void)setCustomNavBarStyle:(UINavigationController *)navigationController {
    [navigationController.navigationBar setBackgroundColor:[UIColor colorNamed:@"VTR_Background"]];
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setShadowImage:[UIImage new]];
}
@end
