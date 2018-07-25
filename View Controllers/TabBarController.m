//
//  TabBarController.m
//  social-maps
//
//  Created by Britney Phan on 7/23/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.tintColor = [UIColor colorNamed:@"VTR_Dark"];
    self.tabBar.unselectedItemTintColor = [UIColor whiteColor];
    
    for (UIViewController *controller in self.viewControllers) {
        controller.title = @"";
        controller.tabBarItem.imageInsets =  UIEdgeInsetsMake(6, 0, -6, 0);
    }
    
    [[self.viewControllers objectAtIndex:0].tabBarItem setImage:[UIImage imageNamed:@"map_icon"]];
    [[self.viewControllers objectAtIndex:1].tabBarItem setImage:[UIImage imageNamed:@"list_icon"]];
    [[self.viewControllers objectAtIndex:2].tabBarItem setImage:[UIImage imageNamed:@"user_icon"]];
    [[self.viewControllers objectAtIndex:3].tabBarItem setImage:[UIImage imageNamed:@"search_icon"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
