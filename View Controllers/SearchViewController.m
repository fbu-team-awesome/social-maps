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
#import "APIManager.h"
#import "ProfileViewController.h"
#import "DetailsViewController.h"

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<GMSPlace*>* places;
@property (strong, nonatomic) NSArray<PFUser*>* users;
@property (strong, nonatomic) NSArray *filteredPlaces;
@property (strong, nonatomic) NSArray *filteredUsers;
@property (assign, nonatomic) long segmentIndex;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray<GMSPlacePhotoMetadata *> *photoMetadata;

@end

@implementation SearchViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self initSearch];
    [self setSegmentControlView];
    [self fetchLists];
    
    // set navbar color
    self.navigationItem.titleView = self.searchBar;
    [self.searchBar setBackgroundColor:[UIColor colorNamed:@"VTR_Background"]];
}

- (void) fetchLists {
    [[APIManager shared] getAllGMSPlaces:^(NSArray<GMSPlace*>* places) {
        self.places = places;
        self.filteredPlaces = self.places;
        [self.tableView reloadData];
    }];
    
    [[APIManager shared] getAllUsers:^(NSArray<PFUser*>* users) {
        self.users = users;
        
        // remove current user from the list
        NSMutableArray<PFUser *> *mutableUsers = [self.users mutableCopy];
        [mutableUsers removeObject:[PFUser currentUser]];
        self.users = [mutableUsers copy];
        
        self.filteredUsers = self.users;
        [self.tableView reloadData];
    }];
}

-(void) initSearch {
    self.searchBar.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setSegmentControlView {
    
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = 60;
    
    // Initialize custom segmented control
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Places", @"Users"]];
    
    // calculate Y position of segmentcontrol
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat statusBarHeight = statusBarFrame.size.height;
    CGFloat navBarHeight = self.navigationController.navigationBar.bounds.size.height;
    CGFloat segmentControlHeight = statusBarHeight + navBarHeight + 12;
    
    // Customize appearance
    [segmentedControl setFrame:CGRectMake(0, segmentControlHeight, width, height)];
    segmentedControl.selectionIndicatorHeight = 4.0f;
    segmentedControl.backgroundColor = [UIColor colorNamed:@"VTR_Background"];
    segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorNamed:@"VTR_BlackLabel"]};
    segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:1.00 green:0.60 blue:0.47 alpha:1.0];
    segmentedControl.selectionIndicatorBoxColor = [UIColor colorNamed:@"VTR_Background"];
    segmentedControl.selectionIndicatorBoxOpacity = 1.0;
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.shouldAnimateUserSelection = YES;
    
    [self.view addSubview:segmentedControl];
    
    // Called when user changes selection
    [segmentedControl setIndexChangeBlock:^(NSInteger index) {
        self.segmentIndex = index;
        [self.view endEditing:YES];
        [self.tableView reloadData];
    }];
    
    // fix the tableview's y position
    CGRect frame = self.tableView.frame;
    frame.origin.y = segmentedControl.frame.origin.y + height;
    self.tableView.frame = frame;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if (self.segmentIndex == 1) {
        UserResultCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"UserResultCell" forIndexPath:indexPath];
        userCell.user = self.filteredUsers[indexPath.row];
        [userCell configureCell];
        cell = userCell;
    } else {
        PlaceResultCell *placeCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceResultCell" forIndexPath:indexPath];
        placeCell.place = self.filteredPlaces[indexPath.row];
        [placeCell configureCell];
        cell = placeCell;
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segmentIndex == 0) {
        return self.filteredPlaces.count;
    }
    return self.filteredUsers.count;
}

#pragma mark - Search Bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0){
        //filter places
        NSPredicate *placePredicate = [NSPredicate predicateWithBlock:^BOOL(GMSPlace *place, NSDictionary *bindings) {
            return [place.name localizedCaseInsensitiveContainsString:searchText];
        }];
        self.filteredPlaces = [self.places filteredArrayUsingPredicate:placePredicate];
        
        //filter users
        NSPredicate *userPredicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *user, NSDictionary *bindings) {
            return [user.username localizedCaseInsensitiveContainsString:searchText];
        }];
        self.filteredUsers = [self.users filteredArrayUsingPredicate:userPredicate];
        
        [self.tableView reloadData];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.filteredPlaces = self.places;
    self.filteredUsers = self.users;
    
    [self.tableView reloadData];
}

#pragma mark - Navigation

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segmentIndex == 0) {
        GMSPlace *place = self.filteredPlaces[indexPath.row];
        [self performSegueWithIdentifier:@"placeSegue" sender:place];
    } else {
        PFUser *user = self.filteredUsers[indexPath.row];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Profile" bundle:NSBundle.mainBundle];
        ProfileViewController *profileVC = [storyboard instantiateViewControllerWithIdentifier:@"Profile"];
        profileVC.user = user;
        [self.navigationController pushViewController:profileVC animated:YES];
    }
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"placeSegue"]) {
         DetailsViewController *detailsVC = (DetailsViewController *)[segue destinationViewController];
         detailsVC.place = sender;
     }
 }
@end
