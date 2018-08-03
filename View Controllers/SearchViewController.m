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
#import "SearchCell.h"
#import "APIManager.h"
#import "ProfileViewController.h"
#import "DetailsViewController.h"

@interface SearchViewController () <UITableViewDelegate, UITableViewDataSource, GMSAutocompleteFetcherDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchFieldView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (strong, nonatomic) NSArray<GMSPlace*>* places;
@property (strong, nonatomic) NSArray<PFUser*>* users;
@property (strong, nonatomic) NSArray *filteredPlaces;
@property (strong, nonatomic) NSArray *filteredUsers;
@property (assign, nonatomic) long segmentIndex;
@property (assign, nonatomic) BOOL isMoreDataLoading;

@property (strong, nonatomic) NSArray<GMSPlacePhotoMetadata *> *photoMetadata;
@property (strong, nonatomic) GMSAutocompleteFetcher *fetcher;
@property (strong, nonatomic) NSArray<GMSAutocompletePrediction *> *predictions;
@end

@implementation SearchViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self initUIStyles];
    [self setSegmentControlView];
    [self fetchPlaces];
    [self fetchUsers];
    
    self.fetcher = [[GMSAutocompleteFetcher alloc] init];
    self.fetcher.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if(indexPath != nil)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)initUIStyles {
    self.searchFieldView.layer.cornerRadius = self.searchFieldView.frame.size.height / 2;
    self.searchFieldView.clipsToBounds = YES;
    self.searchFieldView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.searchFieldView.layer.shadowOffset = CGSizeMake(0, 4);
    self.searchFieldView.layer.shadowRadius = 5;
    self.searchFieldView.layer.shadowOpacity = 0.2;
    self.searchFieldView.layer.masksToBounds = NO;
    
    // set navbar styles
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorNamed:@"VTR_Background"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)fetchPlaces {
    [[APIManager shared] getNextGMSPlacesBatch :^(NSArray<GMSPlace *> *places) {
        if (!self.places) {
            self.places = places;
        }
        else {
            self.places = [self.places arrayByAddingObjectsFromArray:places];
        }
        self.filteredPlaces = self.places;
        [self.tableView reloadData];
        self.isMoreDataLoading = NO;
    }];
}

- (void)fetchUsers {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setSegmentControlView {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = 60;
    
    // Initialize custom segmented control
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Places", @"Users"]];
    
    // calculate Y position of segmentcontrol
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat statusBarHeight = statusBarFrame.size.height;
    CGFloat navBarHeight = self.navigationController.navigationBar.bounds.size.height;
    CGFloat textFieldHeight = self.searchFieldView.frame.size.height;
    CGFloat segmentControlHeight = statusBarHeight + navBarHeight + textFieldHeight + 18;
    
    // Customize appearance
    [segmentedControl setFrame:CGRectMake(0, segmentControlHeight, width, height)];
    segmentedControl.selectionIndicatorHeight = 4.0f;
    segmentedControl.backgroundColor = [UIColor colorNamed:@"VTR_Background"];
    segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorNamed:@"VTR_BlackLabel"], NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Medium" size:17]};
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
    frame.size.height = self.view.frame.size.height - frame.origin.y - self.tabBarController.tabBar.frame.size.height;
    self.tableView.frame = frame;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if (self.segmentIndex == 1) {
        UserResultCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"UserResultCell" forIndexPath:indexPath];
        userCell.user = self.filteredUsers[indexPath.row];
        [userCell configureCell];
        cell = userCell;
    }
    else
    {
        if(indexPath.section == 0)
        {
            PlaceResultCell *placeCell = [tableView dequeueReusableCellWithIdentifier:@"PlaceResultCell" forIndexPath:indexPath];
            placeCell.place = self.filteredPlaces[indexPath.row];
            [placeCell configureCell];
            cell = placeCell;
        }
        else if(indexPath.section == 1)
        {
            SearchCell *searchCell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
            if (self.predictions.count > 0){
                searchCell.prediction = self.predictions[indexPath.row];
                
                [searchCell configureCell];
            }
            
            cell = searchCell;
        }
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segmentIndex == 0)
    {
        if(section == 0)
        {
            return self.filteredPlaces.count;
        }
        else if(section == 1)
        {
            return self.predictions.count;
        }
    }
    return self.filteredUsers.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.segmentIndex == 0)
    {
        return 2;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.segmentIndex == 0)
    {
        if(section == 0)
        {
            return @"Recommended Places";
        }
        else if(section == 1)
        {
            return @"Google Places";
        }
    }
    
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect viewFrame = CGRectMake(0, 0, tableView.frame.size.width, 35);
    UIView *view = [[UIView alloc] initWithFrame:viewFrame];
    [view setBackgroundColor:[UIColor colorNamed:@"VTR_Background"]];
    
    // add label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 9, viewFrame.size.width, 19)];
    [titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:16]];
    [titleLabel setTextColor:[UIColor colorNamed:@"VTR_BlackLabel"]];
    
    // top and bottom borders
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, 1)];
    [topBorder setBackgroundColor:[UIColor colorNamed:@"VTR_Borders"]];
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height, viewFrame.size.width, 1)];
    [bottomBorder setBackgroundColor:[UIColor colorNamed:@"VTR_Borders"]];
    
    if(self.segmentIndex == 0)
    {
        if(section == 0)
        {
            titleLabel.text = @"Recommended Places";
        }
        else if(section == 1)
        {
            titleLabel.text = @"Google Places";
            [view addSubview:topBorder];
        }
    }
    
    [view addSubview:bottomBorder];
    [view addSubview:titleLabel];
    return view;
}
#pragma mark - Search Bar

- (IBAction)searchBarTextChanged:(id)sender {
    NSString *searchText = self.searchTextField.text;
    
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
        [self.fetcher sourceTextHasChanged:self.searchTextField.text];
        [self.tableView reloadData];
    }
    else
    {
        self.filteredPlaces = self.places;
        self.filteredUsers = self.users;
        self.predictions = [NSArray new];
        [self.tableView reloadData];
    }
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
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

- (void)didAutocompleteWithPredictions:(nonnull NSArray<GMSAutocompletePrediction *> *)predictions {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (GMSAutocompletePrediction *prediction in predictions) {
        
        [results addObject:prediction];
        
    }
    self.predictions = [results copy];
}

- (void)didFailAutocompleteWithError:(nonnull NSError *)error {
    NSLog(@"Error fetching autocomplete results: %@", error.localizedDescription);
}

- (IBAction)cancelClicked:(id)sender {
    self.searchTextField.text = @"";
    [self.searchTextField resignFirstResponder];
}

@end
