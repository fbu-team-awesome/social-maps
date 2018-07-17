//
//  SearchResultsViewController.m
//  social-maps
//
//  Created by Bevin Benson on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "DetailsViewController.h"

@interface SearchResultsViewController () <GMSAutocompleteResultsViewControllerDelegate>




@end

@implementation SearchResultsViewController {
    
    GMSAutocompleteResultsViewController *_resultsViewController;
    UISearchController *_searchController;
}
- (void)viewDidLoad {
    
    _resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    _resultsViewController.delegate = self;
    
    _searchController = [[UISearchController alloc]
                         initWithSearchResultsController:_resultsViewController];
    _searchController.searchResultsUpdater = _resultsViewController;
    
    // Put the search bar in the navigation bar.
     [_searchController.searchBar sizeToFit];
     self.navigationItem.titleView = _searchController.searchBar;
    //[self.navigationController addChildViewController:_searchController];
    
    // When UISearchController presents the results view, present it in
    // this view controller, not one further up the chain.
    self.definesPresentationContext = YES;
    
    // Prevent the navigation bar from being hidden when searching.
    _searchController.hidesNavigationBarDuringPresentation = NO;
}

// Handle the user's selection.
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
    _searchController.active = NO;
    
    [self performSegueWithIdentifier:@"toDetailsView" sender: place];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UINavigationController *navController = [segue destinationViewController];
    DetailsViewController *detailsController = (DetailsViewController *)navController.topViewController;
    [detailsController setPlace:sender];
}


- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end
