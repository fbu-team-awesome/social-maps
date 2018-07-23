//
//  ResultsTableViewController.m
//  social-maps
//
//  Created by Britney Phan on 7/18/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "ResultsTableViewController.h"
#import "SearchCell.h"
#import "APIManager.h"

@interface ResultsTableViewController () <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, GMSAutocompleteFetcherDelegate, SearchCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray * results;
@end

@implementation ResultsTableViewController {
    GMSAutocompleteFetcher *_fetcher;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource=self;
    self.tableView.delegate = self;

    
    _fetcher = [[GMSAutocompleteFetcher alloc] init];
    _fetcher.delegate = self;
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
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
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    if (self.results.count > 0){
    cell.prediction = self.results[indexPath.row];
        
        [cell configureCell];
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    //tell GMS fetcher that search text has changed
    [_fetcher sourceTextHasChanged:searchController.searchBar.text];
    
    [self.tableView reloadData];

}



- (void)didAutocompleteWithPredictions:(nonnull NSArray<GMSAutocompletePrediction *> *)predictions {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (GMSAutocompletePrediction *prediction in predictions) {
        
        [results addObject:prediction];
        
    }
    _results = results;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GMSAutocompletePrediction *prediction = _results[indexPath.row];
    [[APIManager shared] GMSPlaceFromID:prediction.placeID withCompletion:^(GMSPlace *place) {
        [self.delegate didSelectPlace:place];
    }];
}

- (void)didFailAutocompleteWithError:(nonnull NSError *)error {
    NSLog(@"Error fetching autocomplete results: %@", error.localizedDescription);
}

- (void) didAddToFavorites:(GMSPlace *)place {
    [Place checkPlaceWithIDExists:place.placeID result:^(Place * result) {
        [result addFavoriteNotification];
    }];
}

- (void)didAddToWishlist:(GMSPlace *)place {
    [Place checkPlaceWithIDExists:place.placeID result:^(Place * result) {
        [result addToWishlistNotification];
    }];
}


@end
