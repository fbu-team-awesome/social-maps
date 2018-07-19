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

@interface ListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *backdropView;
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
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // Initialize custom segmented control
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Favorites", @"Wishlist"]];
    
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
    [self.backdropView addSubview:segmentedControl];
    
    // Called when user changes selection
    [segmentedControl setIndexChangeBlock:^(NSInteger index) {
        
        NSLog(@"Selected index %ld (via block)", (long)index);
        self.segmentIndex = index;
        [self.tableView reloadData];
    }];
    
    /*
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:segmentedControl attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:segmentedControl attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.f];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:segmentedControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:segmentedControl attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f];
    
    [self.view addConstraint: trailing];
    [self.view addConstraint: leading];
    [self.view addConstraint: top];
    [self.view addConstraint:bottom];
     */
}

- (void)initializeConstraints {
    
    
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
 */

 - (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
     
     ListViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ListViewCell" forIndexPath:indexPath];
     
     if (self.segmentIndex == 0) {
         cell.place = self.favorites[indexPath.row];
     }
     else {
         cell.place = self.wishlist[indexPath.row];
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
