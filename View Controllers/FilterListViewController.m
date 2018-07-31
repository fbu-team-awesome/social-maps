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
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSArray *filterNames;

@end

@implementation FilterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.sections = @[@"Your Lists", @"Your Follows", @"Place Categories"];
    self.markerManager = [MarkerManager shared];
    self.filterNames = [self.markerManager.filters allKeys];
    self.tableView.allowsSelection = NO;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FilterCheckboxCell *checkboxCell = [tableView dequeueReusableCellWithIdentifier:@"CheckboxCell" forIndexPath:indexPath];
    
    checkboxCell.list = self.filterNames[indexPath.row];
    checkboxCell.selected = [self.markerManager.filters objectForKey:self.filterNames[indexPath.row]];
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
    return self.markerManager.filters.count - 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section];
}

@end
