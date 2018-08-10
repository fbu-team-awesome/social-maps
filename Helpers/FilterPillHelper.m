//
//  FilterPillHelper.m
//  social-maps
//
//  Created by Bevin Benson on 8/7/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FilterPillHelper.h"
#import "MainMapViewController.h"
#import "PillCancelButton.h"

@implementation FilterPillHelper

+ (instancetype)shared {
    static FilterPillHelper *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (FilterPillView * _Nonnull)createFilterPill:(FilterType)type withName:(NSString * _Nullable)filterName {
    
    FilterPillView *pillView = [[FilterPillView alloc] initWithFrame:CGRectMake(0, 0, 102, 35)];
    pillView.filterType = type;
    pillView.filterName = filterName;
    [pillView setId];
    
    pillView.layer.masksToBounds = NO;
    pillView.layer.shadowColor = [UIColor blackColor].CGColor;
    pillView.layer.shadowOffset = CGSizeMake(0, 1);
    pillView.layer.shadowRadius = 1;
    pillView.layer.shadowOpacity = 0.25;
    pillView.layer.cornerRadius = pillView.frame.size.height / 2;
    
    UIView *pillContent = [[UIView alloc] init];
    
    UILabel *pillText = [[UILabel alloc] init];
    
    PillCancelButton *pillCancel = [[PillCancelButton alloc] init];
    pillCancel.buttonId = pillView.viewId;
    [pillCancel setTitle:@"X" forState:UIControlStateNormal];
    [pillCancel.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:14]];
    
    MainMapViewController *mainMapVC = [[MainMapViewController alloc] init];
    [pillCancel addTarget:mainMapVC action:@selector(pillCancelTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    switch(type) {
        case favFilter: {
            [pillView setBackgroundColor:[UIColor colorNamed:@"VTR_Orange"]];
            [pillText setText:@"Favorites"];
            [pillText setTextColor:[UIColor whiteColor]];
            [pillCancel.titleLabel setTextColor:[UIColor whiteColor]];
            break;
        }
        case wishFilter: {
            [pillView setBackgroundColor:[UIColor colorNamed:@"VTR_Secondary"]];
            [pillText setText:@"Wishlist"];
            [pillText setTextColor:[UIColor whiteColor]];
            [pillCancel.titleLabel setTextColor:[UIColor whiteColor]];
            break;
        }
        case friendFilter: {
            [pillView setBackgroundColor:[UIColor colorNamed:@"VTR_Blue"]];
            [pillText setText:@"Friends"];
            [pillText setTextColor:[UIColor whiteColor]];
            [pillCancel.titleLabel setTextColor:[UIColor whiteColor]];
            break;
        }
        case placeFilter: {
            [pillView setBackgroundColor:[UIColor whiteColor]];
            pillView.layer.borderColor = [UIColor colorNamed:@"VTR_Orange"].CGColor;
            pillView.layer.borderWidth = 1.0f;
            if (filterName) {
                [pillText setText:filterName];
            }
            else {
                [pillText setText:@"Other"];
            }
            [pillText setTextColor:[UIColor colorNamed:@"VTR_GrayLabel"]];
            [pillCancel setTitleColor:[UIColor colorNamed:@"VTR_GrayLabel"] forState:UIControlStateNormal];
            break;
        }
    }
    
    [pillText setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:14]];
    [pillText sizeToFit];
    [pillText setFrame:CGRectMake(0, 0, CGRectGetWidth(pillText.frame), CGRectGetHeight(pillText.frame))];
    [pillContent addSubview:pillText];
    
    [pillCancel setFrame:CGRectMake(pillText.frame.origin.x + CGRectGetWidth(pillText.frame) + 5, pillText.frame.origin.y, 20, 20)];
    [pillContent addSubview:pillCancel];
    
    [pillContent setFrame:CGRectMake(0, 0, pillCancel.frame.origin.x + CGRectGetWidth(pillCancel.frame), 30)];
    [pillView setFrame:CGRectMake(0, 0, CGRectGetWidth(pillContent.frame) + 15, pillView.frame.size.height)];
    [pillText setCenter:CGPointMake(pillText.center.x, pillContent.frame.size.height/2)];
    [pillCancel setCenter:CGPointMake(pillCancel.center.x, pillContent.frame.size.height/2)];
    [pillContent setCenter:CGPointMake(pillView.frame.size.width/2, pillView.frame.size.height/2)];
    [pillView addSubview:pillContent];
    
    return pillView;
}
@end
