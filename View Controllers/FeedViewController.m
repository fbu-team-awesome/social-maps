//
//  FeedViewController.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/30/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FeedViewController.h"
#import "ListAdditionEvent.h"
#import "FeedEvent.h"
#import "AdditionFeedCell.h"

@interface FeedViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<FeedEvent *> *events;
@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set up tableview
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setRowHeight:64];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sortEventsDescendingWithArray:(NSArray *)arrayToSort {
    self.events = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDate *date1 = ((FeedEvent *)obj1).parseObject.createdAt;
        NSDate *date2 = ((FeedEvent *)obj2).parseObject.createdAt;
        return [date2 compare:date1];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedEvent *event = self.events[indexPath.row];
    UITableViewCell *cell = nil;
    
    if(event != nil)
    {
        if(event.eventType == ETCheckin)
        {

        }
        else if(event.eventType == ETListAddition)
        {
            AdditionFeedCell *additionCell = [tableView dequeueReusableCellWithIdentifier:@"AdditionFeedCell" forIndexPath:indexPath];
            [additionCell setEvent:(ListAdditionEvent *)event];
            cell = additionCell;
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
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
