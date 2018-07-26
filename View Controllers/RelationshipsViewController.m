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
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) NSArray<PFUser*>* listedUsers;
@property (nonatomic) RelationshipType relationshipType;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
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
    
    // set up refresh control
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(retrieveUserList) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
    
    // retrieve data
    [self.progressIndicator startAnimating];
    [self retrieveUserList]; 
}

- (void)addNotificationObservers {
    [NCHelper addObserver:self type:NTUnfollow selector:@selector(newUnfollow:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)retrieveUserList {
    if(self.relationshipType == RTFollower)
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

- (void)setUser:(PFUser *)user withRelationshipType:(RelationshipType)relationshipType {
    _user = user;
    _relationshipType = relationshipType;
    
    // update the navbar title
    if(relationshipType == RTFollower)
    {
        self.title = @"Followers";
    }
    else if(relationshipType == RTFollowing)
    {
        self.title = @"Following";
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
    PFUser* user = self.listedUsers[indexPath.row];
    
    if(user != nil)
    {
        [cell setUser:user];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listedUsers.count;
}

- (void)newUnfollow:(NSNotification*)notification {
    PFUser* user = (PFUser*)notification.object;
    
    // remove the unfollowed user from the list
    NSMutableArray<PFUser*>* users = [self.listedUsers mutableCopy];
    [users removeObject:user];
    self.listedUsers = [users copy];
    
    // reload the tableview
    [self.tableView reloadData];
}
@end
