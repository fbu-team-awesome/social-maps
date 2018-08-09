//
//  NotificationsViewController.m
//  social-maps
//
//  Created by César Francisco Barraza on 8/6/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "NotificationsViewController.h"
#import "FollowEvent.h"
#import "NotificationCell.h"
#import "UIStylesHelper.h"

@interface NotificationsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<FollowEvent *> *events;

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUIStyles];
    
    // set up tableview
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    
    // fetch the events
    self.events = [NSArray new];
    [self fetchEvents];
}

- (void)initUIStyles {
    [UIStylesHelper setCustomNavBarStyle:self.navigationController];
    [UIStylesHelper addShadowToView:self.navigationController.navigationBar withOffset:CGSizeMake(0, 2) withRadius:1.5 withOpacity:0.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchEvents {
    PFQuery *query = [PFQuery queryWithClassName:@"FeedEvent"];
    PFUser *currentUser = [PFUser currentUser];
    NSMutableArray<FollowEvent *> *mutableArray = [NSMutableArray new];
    
    // fetch all follow events that have the current user as the one being followed
    [query whereKey:@"eventType" equalTo:[NSNumber numberWithUnsignedInteger:ETFollow]];
    [query whereKey:@"followingID" equalTo:currentUser.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for(PFObject *object in objects)
        {
            [mutableArray addObject:[[FollowEvent alloc] initWithParseObject:object]];
        }
        
        self.events = [mutableArray copy];
        [self sortEventsDescending];
        [self.tableView reloadData];
    }];
}

- (void)sortEventsDescending {
    self.events = [self.events sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDate *date1 = ((FollowEvent *)obj1).parseObject.createdAt;
        NSDate *date2 = ((FollowEvent *)obj2).parseObject.createdAt;
        return [date2 compare:date1];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell" forIndexPath:indexPath];
    FollowEvent *event = self.events[indexPath.row];
    
    if(event != nil)
    {
        [cell setEvent:event];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}
@end
