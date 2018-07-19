//
//  UserTest.m
//  social-maps
//
//  Created by Bevin Benson on 7/18/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "UserTest.h"
#import "Relationships.h"
#import "UserTestCell.h"

@interface UserTest ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *users;

@end

@implementation UserTest

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setRowHeight:170];
    // Do any additional setup after loading the view.
    
    [Relationships getUsersWithCompletion:^(NSArray *users) {
        self.users = users;
        [self.tableView reloadData];
        NSLog(@"Done");
    }];
    
    [self.tableView reloadData];

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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UserTestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTestCell" forIndexPath:indexPath];
    cell.user = self.users[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.users.count;
}
@end
