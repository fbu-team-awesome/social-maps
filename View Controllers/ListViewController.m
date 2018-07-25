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

static NSString* NO_FAVORITE_MSG = @"You have no favorites!";
static NSString* NO_WISHLIST_MSG = @"You have no places in your wishlist!";

@interface ListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *defaultView;
@property (weak, nonatomic) IBOutlet UILabel *defaultViewLabel;
@property (strong, nonatomic) NSArray<GMSPlace*>* favorites;
@property (strong, nonatomic) NSArray<GMSPlace*>* wishlist;
@property (assign, nonatomic) long segmentIndex;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressIndicator;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setView)
                                                 name:@"AddFavoriteNotification"
                                               object:nil];
    // add notification listener for adding to wishlist
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setView)
                                                 name:@"AddToWishlistNotification"
                                               object:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = NO;
    self.defaultView.hidden = YES;
    [self.tableView setRowHeight:91];
    [self setSegmentControlView];
    [self retrieveCurrentUserData];
}

- (void)setView {
    
    self.defaultView.hidden = YES;
    self.tableView.hidden = NO;
    if (self.favorites == nil && self.segmentIndex == 0) {
        self.defaultViewLabel.text = @"Your Favorites is currently empty!";
        self.tableView.hidden = YES;
        self.defaultView.hidden = NO;
    }
    else if (self.wishlist == nil && self.segmentIndex == 1) {
        self.defaultViewLabel.text = @"Your Wishlist is currently empty!";
        self.tableView.hidden = YES;
        self.defaultView.hidden = NO;
    }
    else {
        self.tableView.hidden = NO;
        self.defaultView.hidden = YES;
    }
    
    
}

- (void)retrieveCurrentUserData {
    [self.progressIndicator startAnimating];
    PFUser *currentUser = [PFUser currentUser];
    [currentUser retrieveFavoritesWithCompletion:^(NSArray<GMSPlace *> *favorites) {
        if(favorites != nil)
        {
            self.favorites = favorites;
            
            // hide default label
            self.defaultView.hidden = YES;
            self.tableView.hidden = NO;
        }
        else
        {
            // show default label
            if(self.segmentIndex == 0)
            {
                self.defaultViewLabel.text = NO_FAVORITE_MSG;
                self.tableView.hidden = YES;
                self.defaultView.hidden = NO;
            }
        }
        [self.tableView reloadData];
        [self.progressIndicator stopAnimating];
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
    segmentedControl.backgroundColor = [UIColor colorNamed:@"VTR_LightOrange"];
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
     
     if (self.segmentIndex == 0) {
         [self setView];
         return self.favorites.count;
     }
     else {
         [self setView];
         return self.wishlist.count;
     }
 }
@end
