//
//  UserTest.m
//  social-maps
//
//  Created by Bevin Benson on 7/18/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "UserTest.h"
#import "UserFriends.h"

@interface UserTest ()

@end

@implementation UserTest

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *users = [UserFriends getUsers];
    NSLog(@"Retrieve users");

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
