//
//  RelationshipsViewController.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "PFUser+ExtendedUser.h"
#import "RelationshipsViewController.h"
#import "RelationshipListCell.h"
#import "ProfileViewController.h"

@interface RelationshipsViewController () <UITableViewDataSource, UITableViewDelegate>
// Outlet Definitions //
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Instance Properties //
@property (strong, nonatomic) NSArray<PFUser*>* users;
@end

@implementation RelationshipsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // set up tableview
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setRowHeight:55.5];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUsers:(NSArray<PFUser*>*)users {
    _users = users;
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"profileSegue"])
    {
        ProfileViewController* vc = (ProfileViewController*)[segue destinationViewController];
        RelationshipListCell* cell = (RelationshipListCell*)sender;
        [vc setUser:[cell getUser]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RelationshipListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RelationshipListCell" forIndexPath:indexPath];
    PFUser* user = self.users[indexPath.row];
    
    if(user != nil)
    {
        [cell setUser:user];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}
@end
