//
//  FeedViewController.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedEvent.h"
#import "ListAdditionEvent.h"
#import "CheckInEvent.h"
#import "PhotoAdditionEvent.h"
#import "ReviewAdditionEvent.h"
#import "AdditionFeedCell.h"
#import "CheckinFeedCell.h"
#import "PhotoFeedCell.h"
#import "ReviewFeedCell.h"
#import "NCHelper.h"

@interface FeedViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<FeedEvent *> *events;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNotificationObservers];
    
    // set up tableview
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setRowHeight:64];
    
    // set up refresh control
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(fetchEvents) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
    
    self.events = [NSArray new];
    [self fetchEvents];
}

- (void)addNotificationObservers {
    [NCHelper addObserver:self type:NTNewFeedEvent selector:@selector(newFeedEventAdded:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchEvents {
    PFQuery *query = [PFQuery queryWithClassName:@"FeedEvent"];
    PFUser *currentUser = [PFUser currentUser];
    
    // get events from current user
    [query whereKey:@"user" equalTo:currentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.events = [NSArray new];
        if(objects != nil)
        {
            [self addEventsWithArray:objects];
            
            // get the events from the user's following
            [currentUser retrieveRelationshipWithCompletion:^(Relationships *relationship) {
                if(relationship.following.count > 0)
                {
                    [PFUser retrieveUsersWithIDs:relationship.following
                                  withCompletion:^(NSArray<PFUser *> *users) {
                                      for(int i = 0; i < users.count; i++)
                                      {
                                          PFUser *user = users[i];
                                          PFQuery *newQuery = [PFQuery queryWithClassName:@"FeedEvent"];
                                          [newQuery whereKey:@"user" equalTo:user];
                                          [newQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                                              [self addEventsWithArray:objects];
                                              
                                              // if we're finished, sort the array by date (descending)
                                              if(i == users.count - 1)
                                              {
                                                  [self sortEventsDescending];
                                                  [self.tableView reloadData];
                                                  [self.refreshControl endRefreshing];
                                              }
                                          }];
                                      }
                                  }];
                }
                else
                {
                    [self sortEventsDescending];
                    [self.tableView reloadData];
                    [self.refreshControl endRefreshing];
                }
            }];
        }
    }];
}

- (void)sortEventsDescending {
    self.events = [self.events sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDate *date1 = ((FeedEvent *)obj1).parseObject.createdAt;
        NSDate *date2 = ((FeedEvent *)obj2).parseObject.createdAt;
        return [date2 compare:date1];
    }];
}

- (void)addEventsWithArray:(NSArray<PFObject *> *)objects {
    NSMutableArray<FeedEvent *> *temp = [NSMutableArray new];
    for(PFObject *object in objects)
    {
        FeedEventType eventType = [object[@"eventType"] unsignedIntegerValue];
        if(eventType == ETListAddition)
        {
            [temp addObject:[[ListAdditionEvent alloc] initWithParseObject:object]];
        }
        else if(eventType == ETCheckin)
        {
            [temp addObject:[[CheckInEvent alloc] initWithParseObject:object]];
        }
        else if(eventType == ETPhotoAddition)
        {
            [temp addObject:[[PhotoAdditionEvent alloc] initWithParseObject:object]];
        }
        else if(eventType == ETReviewAddition)
        {
            [temp addObject:[[ReviewAdditionEvent alloc] initWithParseObject:object]];
        }
    }
    
    // add the temporary array to our events array
    self.events = [self.events arrayByAddingObjectsFromArray:[temp copy]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedEvent *event = self.events[indexPath.row];
    UITableViewCell *cell = nil;
    
    if(event != nil)
    {
       if(event.eventType == ETListAddition)
        {
            AdditionFeedCell *additionCell = [tableView dequeueReusableCellWithIdentifier:@"AdditionFeedCell" forIndexPath:indexPath];
            [additionCell setEvent:(ListAdditionEvent *)event];
            cell = additionCell;
        }
        else if(event.eventType == ETCheckin)
        {
            CheckinFeedCell *checkinCell = [tableView dequeueReusableCellWithIdentifier:@"CheckinFeedCell" forIndexPath:indexPath];
            [checkinCell setEvent:(CheckInEvent *)event];
            cell = checkinCell;
        }
        else if(event.eventType == ETPhotoAddition)
        {
            PhotoFeedCell *photoCell = [tableView dequeueReusableCellWithIdentifier:@"PhotoFeedCell" forIndexPath:indexPath];
            [photoCell setEvent:(PhotoAdditionEvent *)event];
            cell = photoCell;
        }
        else if(event.eventType == ETReviewAddition)
        {
            ReviewFeedCell *reviewCell = [tableView dequeueReusableCellWithIdentifier:@"ReviewFeedCell" forIndexPath:indexPath];
            [reviewCell setEvent:(ReviewAdditionEvent *)event];
            cell = reviewCell;
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (void)newFeedEventAdded:(NSNotification *)notification {
    FeedEvent *event = (FeedEvent *)notification.object;
    self.events = [[NSArray arrayWithObject:event] arrayByAddingObjectsFromArray:self.events];
    [self.tableView reloadData];
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
