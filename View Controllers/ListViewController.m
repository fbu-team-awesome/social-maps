//
//  ListViewController.m
//  social-maps
//
//  Created by Bevin Benson on 7/17/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "ListViewController.h"
#import "ListViewCell.h"
#import "PFUser+ExtendedUser.h"
#import "HMSegmentedControl.h"
#import "ProfileListCell.h"
#import "DetailsViewController.h"

@interface ListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray<GMSPlace*>* favorites;
@property (strong, nonatomic) NSArray<GMSPlace*>* wishlist;
@property (assign, nonatomic) long segmentIndex;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setRowHeight:91];
    [self setSegmentControlView];
    [self retrieveCurrentUserData];
}

- (void)retrieveCurrentUserData {
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser retrieveFavoritesWithCompletion:^(NSArray<GMSPlace *> *favorites) {
        
        self.favorites = favorites;
        [self.tableView reloadData];
    }];
    [currentUser retrieveWishlistWithCompletion:^(NSArray<GMSPlace *> *wishlist) {
        
        self.wishlist = wishlist;
        [self.tableView reloadData];
    }];
}

- (void)setSegmentControlView {
    // hide nav bar
    [self.navigationController setNavigationBarHidden:YES];
    
    // get status bar height
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat statusBarHeight = statusBarFrame.size.height;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // Initialize custom segmented control
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Favorites", @"Wishlist"]];
    
    // Customize appearance
    [segmentedControl setFrame:CGRectMake(0, statusBarHeight, width, 60)];
    segmentedControl.selectionIndicatorHeight = 4.0f;
    segmentedControl.backgroundColor = [UIColor colorWithRed:1.00 green:0.92 blue:0.87 alpha:1.0];
    segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:1.00 green:0.60 blue:0.47 alpha:1.0]};
    segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:1.00 green:0.60 blue:0.47 alpha:1.0];
    segmentedControl.selectionIndicatorBoxColor = [UIColor colorWithRed:1.00 green:0.92 blue:0.87 alpha:1.0];
    segmentedControl.selectionIndicatorBoxOpacity = 1.0;
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.shouldAnimateUserSelection = YES;
    [self.view addSubview:segmentedControl];
    
    // Called when user changes selection
    [segmentedControl setIndexChangeBlock:^(NSInteger index) {
        
        NSLog(@"Selected index %ld (via block)", (long)index);
        self.segmentIndex = index;
        [self.tableView reloadData];
    }];
    
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.origin.y = statusBarHeight + 60;
    self.tableView.frame = tableViewFrame;
    // set tableview constraints in respect to segmented control
    //self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor].active = YES;
//    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor].active = YES;
//    [self.tableView.topAnchor constraintEqualToAnchor:segmentedControl.bottomAnchor].active = YES;
    
}

- (void)initializeConstraints {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"detailsSegue"])
    {
        DetailsViewController* vc = (DetailsViewController*)[segue destinationViewController];
        ProfileListCell* cell = (ProfileListCell*)sender;
        [vc setPlace:[cell getPlace]];
    }
}

 - (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
     ProfileListCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProfileListCell" forIndexPath:indexPath];
     
     if (self.segmentIndex == 0) {
         [cell setPlace:self.favorites[indexPath.row]];
     }
     else {
         [cell setPlace:self.wishlist[indexPath.row]];
     }
     return cell;
 }
 
 - (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     
     if (self.segmentIndex == 0)
         return self.favorites.count;
     else
         return self.wishlist.count;
 }


@end
