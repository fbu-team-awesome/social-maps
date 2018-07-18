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

@interface ListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *listSelector;
@property (strong, nonatomic) NSArray<Place*>* favorites;
@property (strong, nonatomic) NSArray<Place*>* wishlist;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    PFUser *currentUser = [PFUser currentUser];
    self.favorites = currentUser.favorites;
    self.wishlist = currentUser.wishlist;
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
     
     if (self.listSelector.selectedSegmentIndex == 0) {
         
         cell.place = self.favorites[indexPath.row];
     }
     else {
         
         cell.place = self.wishlist[indexPath.row];
     }
     
     return cell;
 }
 
 - (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     
     if (self.listSelector.selectedSegmentIndex == 0)
         return self.favorites.count;
     else
         return self.wishlist.count;
 }

@end