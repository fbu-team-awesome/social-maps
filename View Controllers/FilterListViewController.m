//
//  FilterListViewController.m
//  social-maps
//
//  Created by Bevin Benson on 7/31/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FilterListViewController.h"
#import "FilterCheckboxCell.h"
#import "MarkerManager.h"
#import "UIStylesHelper.h"

@interface FilterListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MarkerManager *markerManager;
@property (strong, nonatomic) NSArray<NSString *> *sectionTitles;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSMutableArray *> *sections;

@end

@implementation FilterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.markerManager = [MarkerManager shared];
    [self organizeFiltersIntoSections];
    
    self.tableView.allowsSelection = NO;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar.topItem setTitle:@"Filters"];
    
    // set navbar styles
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorNamed:@"VTR_Background"]];
    [UIStylesHelper addShadowToView:self.navigationController.navigationBar withOffset:CGSizeMake(0, 2) withRadius:1.5 withOpacity:0.1];
    
    // show navbar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)organizeFiltersIntoSections {
    self.sectionTitles = @[@"Your Lists", @"Your Friends", @"Places Categories"];
    NSArray *filterNames = [MarkerManager shared].filterKeys;
    
    self.sections = [NSMutableDictionary new];
    
    [self.sections setObject:[NSMutableArray new] forKey:self.sectionTitles[0]];
    [self.sections setObject:[NSMutableArray new] forKey:self.sectionTitles[1]];
    [self.sections setObject:[NSMutableArray new] forKey:self.sectionTitles[2]];
    
    for (NSString *filterName in filterNames) {
        if ([filterName isEqualToString:kFavoritesKey] || [filterName isEqualToString:kWishlistKey]) {
            [[self.sections objectForKey:self.sectionTitles[0]] addObject:filterName];
        }
        else if ([filterName isEqualToString:kFollowFavKey]) {
            [[self.sections objectForKey:self.sectionTitles[1]] addObject:filterName];
        }
        else {
            [[self.sections objectForKey:self.sectionTitles[2]] addObject:filterName];
        }
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FilterCheckboxCell *checkboxCell = [tableView dequeueReusableCellWithIdentifier:@"CheckboxCell" forIndexPath:indexPath];
    
    // gets the list names in the section
    NSArray *listsOfSection = [self.sections objectForKey:self.sectionTitles[indexPath.section]];
    NSString *listName = listsOfSection[indexPath.row];
    checkboxCell.list = listName;
    checkboxCell.selected = [[self.markerManager.allFilters objectForKey:listName] boolValue];
    [checkboxCell configureCell];
    
    return checkboxCell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:14];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    else if (section == 1) {
        return 1;
    }
    return self.markerManager.allFilters.count - 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}

- (IBAction)clearAllClicked:(id)sender {
    MarkerManager *markerManager = [MarkerManager shared];
    NSMutableDictionary *mutableAllFilters = [NSMutableDictionary new];
    NSMutableDictionary *mutablePlaceFilters = [NSMutableDictionary new];
    NSMutableDictionary *mutableTypeFilters = [NSMutableDictionary new];
    
    for (NSString *key in markerManager.typeFilters) {
        [mutableTypeFilters setObject:[NSNumber numberWithBool:NO] forKey:key];
    }
    for (NSString *key in markerManager.placeFilters) {
        [mutablePlaceFilters setObject:[NSNumber numberWithBool:NO] forKey:key];
    }
    for (NSString *key in markerManager.allFilters) {
        [mutableAllFilters setObject:[NSNumber numberWithBool:NO] forKey:key];
    }
    markerManager.allFilters = mutableAllFilters;
    markerManager.placeFilters = mutablePlaceFilters;
    markerManager.typeFilters = mutableTypeFilters;
    
    NSMutableArray<FilterCheckboxCell *> *cells = [NSMutableArray new];
    for (NSInteger i = 0; i < self.tableView.numberOfSections; i++) {
        for (NSInteger j = 0; j < [self.tableView numberOfRowsInSection:i]; j++) {
            FilterCheckboxCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            if (cell != nil) {
                [cells addObject:cell];
            }
        }
    }
    for (FilterCheckboxCell *cell in cells) {
        [cell uncheckCell];
    }
}

- (IBAction)doneClicked:(id)sender {
    [self.delegate filterSelectionDone];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
