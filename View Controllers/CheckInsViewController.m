//
//  CheckInsViewController.m
//  social-maps
//
//  Created by Britney Phan on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "CheckInsViewController.h"
#import "PFUser+ExtendedUser.h"
#import "RelationshipListCell.h"

@interface CheckInsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CheckInsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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
    RelationshipListCell *userCell = [self.tableView dequeueReusableCellWithIdentifier:@"CheckInCell" forIndexPath:indexPath];
    [userCell setUser:self.users[indexPath.row]];
    return userCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

@end
