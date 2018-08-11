//
//  UIStylesHelper.m
//  social-maps
//
//  Created by César Francisco Barraza on 8/6/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "UIStylesHelper.h"

@implementation UIStylesHelper
+ (void)addRoundedCornersToView:(UIView *)view {
    CGFloat min = MIN(view.frame.size.width, view.frame.size.height);
    view.layer.cornerRadius = min / 2;
    view.clipsToBounds = YES;
}

+ (void)addShadowToView:(UIView *)view {
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.shadowRadius = 5;
    view.layer.shadowOpacity = 0.2;
    view.layer.masksToBounds = NO;
}

+ (void)addShadowToView:(UIView *)view withOffset:(CGSize)offset withRadius:(CGFloat)radius withOpacity:(float)opacity {
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = offset;
    view.layer.shadowRadius = radius;
    view.layer.shadowOpacity = opacity;
    view.layer.masksToBounds = NO;
}

+ (void)addGradientToView:(UIView *)view {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.layer.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorNamed:@"VTR_Orange"].CGColor, (id)[UIColor colorNamed:@"VTR_Main"].CGColor, nil];
    gradientLayer.cornerRadius = view.layer.cornerRadius;
    [view.layer insertSublayer:gradientLayer atIndex:0];
}

+ (void)setCustomNavBarStyle:(UINavigationController *)navigationController {
    [navigationController.navigationBar setBackgroundColor:[UIColor colorNamed:@"VTR_Background"]];
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setShadowImage:[UIImage new]];
}

+ (void)animateTapOnView:(UIView *)view {
    [UIView animateWithDuration:0.1 animations:^{
        view.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            view.transform = CGAffineTransformIdentity;
        }];
    }];
    
    // haptic feedback
    [[UIImpactFeedbackGenerator new] impactOccurred];
}
@end
