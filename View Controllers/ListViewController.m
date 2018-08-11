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
#import "NCHelper.h"
#import "UIStylesHelper.h"

static NSString *const kNoFavoriteMsg = @"You have no favorites!";
static NSString *const kNoWishlistMsg = @"You have no places in your wishlist!";

@interface ListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *defaultView;
@property (weak, nonatomic) IBOutlet UILabel *defaultViewLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressIndicator;

@property (strong, nonatomic) NSArray<GMSPlace *> *favorites;
@property (strong, nonatomic) NSArray<GMSPlace *> *wishlist;
@property (assign, nonatomic) long segmentIndex;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotificationObservers];
    
    // initialize arrays
    self.favorites = [NSArray new];
    self.wishlist = [NSArray new];
    
    // set up tableview
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self toggleDefaultViewHidden:YES];
    
    [self.tableView setRowHeight:91];
    [self setSegmentControlView];
    [self.progressIndicator startAnimating];
    [self retrieveCurrentUserData];
    
    // initialize refresh control
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(retrieveCurrentUserData) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    // set navbar styles
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorNamed:@"VTR_Background"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillAppear:(BOOL)animated {
    // make sure navbar has no shadow
    [UIStylesHelper addShadowToView:self.navigationController.navigationBar withOffset:CGSizeZero withRadius:0 withOpacity:0];
    
    // deselect cell
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if(indexPath != nil)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)addNotificationObservers {
    [NCHelper addObserver:self type:NTAddFavorite selector:@selector(didAddFavorite:)];
    [NCHelper addObserver:self type:NTRemoveFavorite selector:@selector(didRemoveFavorite:)];
    [NCHelper addObserver:self type:NTAddToWishlist selector:@selector(didAddToWishlist:)];
    [NCHelper addObserver:self type:NTRemoveFromWishlist selector:@selector(didRemoveFromWishlist:)];
}

- (void)retrieveCurrentUserData {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser retrieveFavoritesWithCompletion:^(NSArray<GMSPlace *> *favorites) {
        if(favorites.count > 0)
        {
            self.favorites = favorites;
            
            // hide default label
            [self toggleDefaultViewHidden:YES];
        }
        else
        {
            // show default label
            if(self.segmentIndex == 0)
            {
                self.defaultViewLabel.text = kNoFavoriteMsg;
                [self toggleDefaultViewHidden:NO];
            }
        }
        [self.tableView reloadData];
        [self.progressIndicator stopAnimating];
        [self.refreshControl endRefreshing];
    }];
    
    [currentUser retrieveWishlistWithCompletion:^(NSArray<GMSPlace *> *wishlist) {
        if(wishlist.count > 0)
        {
            self.wishlist = wishlist;
            
            // hide default label
            [self toggleDefaultViewHidden:YES];
        }
        else
        {
            // show default label
            if(self.segmentIndex == 1)
            {
                self.defaultViewLabel.text = kNoWishlistMsg;
                [self toggleDefaultViewHidden:NO];
            }
        }
        [self.tableView reloadData];
        [self.progressIndicator stopAnimating];
        [self.refreshControl endRefreshing];
    }];
}

- (void)setSegmentControlView {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // Initialize custom segmented control
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Favorites", @"Wishlist"]];
    
    // Customize appearance
    // Customize appearance
    [segmentedControl setFrame:CGRectMake(0, 0, width, 55)];
    segmentedControl.selectionIndicatorHeight = 4.5f;
    segmentedControl.backgroundColor = [UIColor colorNamed:@"VTR_Background"];
    segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorNamed:@"VTR_BlackLabel"], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-DemiBold" size:15.5]};
    segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorNamed:@"VTR_Main"], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-DemiBold" size:15.5]};
    segmentedControl.selectionIndicatorColor = [UIColor colorNamed:@"VTR_Main"];
    segmentedControl.selectionIndicatorBoxColor = [UIColor colorNamed:@"VTR_Background"];
    segmentedControl.selectionIndicatorBoxOpacity = 1.0;
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.shouldAnimateUserSelection = YES;
    
    // add shadow
    segmentedControl.layer.shadowColor = [UIColor blackColor].CGColor;
    segmentedControl.layer.shadowOffset = CGSizeMake(0, 3);
    segmentedControl.layer.shadowRadius = 2;
    segmentedControl.layer.shadowOpacity = 0.1;
    segmentedControl.layer.masksToBounds = NO;
    [self.view addSubview:segmentedControl];
    
    // Called when user changes selection
    [segmentedControl setIndexChangeBlock:^(NSInteger index) {
        
        NSLog(@"Selected index %ld (via block)", (long)index);
        [self.progressIndicator startAnimating];
        self.segmentIndex = index;
        
        // we changed to wishlist
        if(index == 1)
        {
            if(self.wishlist.count == 0)
            {
                self.defaultViewLabel.text = kNoWishlistMsg;
                [self toggleDefaultViewHidden:NO];
            }
            else
            {
                [self toggleDefaultViewHidden:YES];
            }
        }
        // we changed to favorites
        else if(index == 0)
        {
            if(self.favorites.count == 0)
            {
                self.defaultViewLabel.text = kNoFavoriteMsg;
                [self toggleDefaultViewHidden:NO];
            }
            else
            {
                [self toggleDefaultViewHidden:YES];
            }
        }
        [self.tableView reloadData];
        [self.progressIndicator stopAnimating];
    }];
    
    
    // fix the tableview's y position
    CGRect frame = self.tableView.frame;
    frame.origin.y = segmentedControl.frame.origin.y + 55;
    frame.size.height = self.view.frame.size.height - frame.origin.y - self.tabBarController.tabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20;
    self.tableView.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"detailsSegue"])
    {
        DetailsViewController *vc = (DetailsViewController *)[segue destinationViewController];
        ProfileListCell *cell = (ProfileListCell *)sender;
        [vc setPlace:[cell getPlace]];
    }
}

 - (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
     ProfileListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProfileListCell" forIndexPath:indexPath];
     
     if (self.segmentIndex == 0) {
         GMSPlace *place = self.favorites[indexPath.row];
         cell.pictureImage.image = self.placeImages[place.placeID];
         [cell setPlace:place];
     }
     else {
         GMSPlace *place = self.wishlist[indexPath.row];
         cell.pictureImage.image = self.placeImages[place.placeID];
         [cell setPlace:place];
     }
     return cell;
 }
 
 - (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     
     if (self.segmentIndex == 0) {
         return self.favorites.count;
     }
     else {
         return self.wishlist.count;
     }
     
}

- (void)toggleDefaultViewHidden:(BOOL)shouldHideDefaultView {
    self.tableView.hidden = !shouldHideDefaultView;
    self.defaultView.hidden = shouldHideDefaultView;
}

- (void)didAddFavorite:(NSNotification *)notification {
    GMSPlace *place = (GMSPlace *)notification.object;
    
    // add to the favorites
    self.favorites = [[NSArray arrayWithObject:place] arrayByAddingObjectsFromArray:self.favorites];
    
    // reload table
    [self.tableView reloadData];
    
    // hide default label
    if(self.segmentIndex == 0)
    {
        [self toggleDefaultViewHidden:YES];
    }
}

- (void)didRemoveFavorite:(NSNotification *)notification {
    GMSPlace *place = (GMSPlace *)notification.object;
    
    // remove from favorites
    NSMutableArray<GMSPlace *> *favorites = [self.favorites mutableCopy];
    [favorites removeObject:place];
    self.favorites = [favorites copy];
    
    // reload table
    [self.tableView reloadData];
    
    // show default label if we have no favorites
    if(self.segmentIndex == 0 && self.favorites.count == 0)
    {
        self.defaultViewLabel.text = kNoFavoriteMsg;
        [self toggleDefaultViewHidden:NO];
    }
}

- (void)didAddToWishlist:(NSNotification *)notification {
    GMSPlace *place = (GMSPlace *)notification.object;
    
    // add to the wishlist
    self.wishlist = [[NSArray arrayWithObject:place] arrayByAddingObjectsFromArray:self.wishlist];
    
    // reload table
    [self.tableView reloadData];
    
    // hide default label
    if(self.segmentIndex == 1)
    {
        [self toggleDefaultViewHidden:YES];
    }
}

- (void)didRemoveFromWishlist:(NSNotification *)notification {
    GMSPlace *place = (GMSPlace *)notification.object;
    
    // remove from wishlist
    NSMutableArray<GMSPlace *> *wishlist = [self.wishlist mutableCopy];
    [wishlist removeObject:place];
    self.wishlist = [wishlist copy];
    
    // reload table
    [self.tableView reloadData];
    
    // show default label if we have no wishlist
    if(self.segmentIndex == 1 && self.wishlist.count == 0)
    {
        self.defaultViewLabel.text = kNoWishlistMsg;
        [self toggleDefaultViewHidden:NO];
    }
    
}
@end
