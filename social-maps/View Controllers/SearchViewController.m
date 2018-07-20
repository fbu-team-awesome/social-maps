//
//  SearchViewController.m
//  social-maps
//
//  Created by Britney Phan on 7/19/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "SearchViewController.h"
#import "ResultsTableViewController.h"
#import "HMSegmentedControl.h"
#import "PlaceResultCell.h"
#import "UserResultCell.h"


@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray * places;
@property (strong, nonatomic) NSArray * users;
@property (assign, nonatomic) long segmentIndex;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //self.definesPresentationContext = true;
    //[self initSearch];
    [self setSegmentControlView];
    [self fetchLists];
    [self.tableView reloadData];
    
}

- (void) fetchLists {
    
}

//initialize search controller
-(void) initSearch {
    
    _searchBar.showsScopeBar = YES;
    _searchBar.scopeButtonTitles = @[@"Places",@"Users"];
}


- (void)setSegmentControlView {
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // Initialize custom segmented control
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Places", @"Users"]];
    
    // Customize appearance
    [segmentedControl setFrame:CGRectMake(0, 0, width, 60)];
    segmentedControl.selectionIndicatorHeight = 4.0f;
    segmentedControl.backgroundColor = [UIColor colorWithRed:1.00 green:0.92 blue:0.87 alpha:1.0];
    segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:1.00 green:0.60 blue:0.47 alpha:1.0]};
    segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:1.00 green:0.60 blue:0.47 alpha:1.0];
    segmentedControl.selectionIndicatorBoxColor = [UIColor colorWithRed:1.00 green:0.92 blue:0.87 alpha:1.0];
    segmentedControl.selectionIndicatorBoxOpacity = 1.0;
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    // segmentedControl.selectedSegmentIndex = HMSegmentedControlNoSegment;
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.shouldAnimateUserSelection = YES;
    // segmentedControl3.tag = 2;
    [self.view addSubview:segmentedControl];
    
    // Called when user changes selection
    [segmentedControl setIndexChangeBlock:^(NSInteger index) {
        
        NSLog(@"Selected index %ld (via block)", (long)index);
        self.segmentIndex = index;
        [self.tableView reloadData];
    }];

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
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    if (self.segmentIndex == 0) {
        PlaceResultCell * placeCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceResultCell" forIndexPath:indexPath];
        cell = placeCell;
    } else {
        UserResultCell * userCell = [tableView dequeueReusableCellWithIdentifier:@"UserResultCell" forIndexPath:indexPath];
        cell = userCell;
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segmentIndex == 0) {
        return self.places.count;
    }
    return self.users.count;
}


@end
