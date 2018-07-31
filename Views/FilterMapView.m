//
//  FilterMapView.m
//  social-maps
//
//  Created by Bevin Benson on 7/31/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FilterMapView.h"

@implementation FilterMapView

- (void)initView {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(toFilterList:) forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Filters" forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
    [self addSubview:button];
}


@end
