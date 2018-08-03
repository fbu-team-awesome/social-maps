//
//  FilterListViewController.m
//  social-maps
//
//  Created by Bevin Benson on 7/31/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "FilterListViewController.h"
#import "MarkerManager.h"
#import "FilterCheckboxCell.h"

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

- (void)organizeFiltersIntoSections {
    self.sectionTitles = @[@"Your Lists", @"Lists of Your Follows", @"Places Categories"];
    NSArray *filterNames = [self.markerManager.allFilters allKeys];
    
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

- (IBAction)doneClicked:(id)sender {
    [self.delegate filterSelectionDone];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
