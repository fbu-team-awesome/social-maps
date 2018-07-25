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
#import "NCHelper.h"

@interface RelationshipsViewController () <UITableViewDataSource, UITableViewDelegate>
// Outlet Definitions //
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressIndicator;

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
    
    [self addNotificationObservers];
}

- (void)addNotificationObservers {
    [NCHelper addObserver:self type:NTUnfollow selector:@selector(newUnfollow:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUsers:(NSArray<PFUser*>*)users {
    _users = users;
    [self.tableView reloadData];
- (void)retrieveUserList {
    if(self.relationshipType == RTFollowers)
    {
        [PFUser retrieveUsersWithIDs:self.user.relationships.followers
                      withCompletion:^(NSArray<PFUser *> *followers)
                      {
                          self.listedUsers = followers;
                          [self.tableView reloadData];
                          [self.progressIndicator stopAnimating];
                          [self.refreshControl endRefreshing];
                      }];
    }
    else if(self.relationshipType == RTFollowing)
    {
        [PFUser retrieveUsersWithIDs:self.user.relationships.following
                      withCompletion:^(NSArray<PFUser *> *following)
                      {
                          self.listedUsers = following;
                          [self.tableView reloadData];
                          [self.progressIndicator stopAnimating];
                          [self.refreshControl endRefreshing];
                      }];
    }
}
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

- (void)newUnfollow:(NSNotification*)notification {
    PFUser* user = (PFUser*)notification.object;
    
    // remove the unfollowed user from the list
    NSMutableArray<PFUser*>* users = (NSMutableArray*)self.users;
    [users removeObject:user];
    self.users = (NSArray*)users;
    
    // reload the tableview
    [self.tableView reloadData];
}
@end
