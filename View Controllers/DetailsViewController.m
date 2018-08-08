//
//  DetailsViewController.m
//  social-maps
//
//  Created by Britney Phan on 7/17/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "DetailsViewController.h"
#import "NCHelper.h"
#import "PFUser+ExtendedUser.h"
#import "Place.h"
#import "ParseImageHelper.h"
#import "CheckInsViewController.h"
#import "Relationships.h"
#import "AlertHelper.h"
#import "ImageHelper.h"
#import "PhotoCell.h"
#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import "HCSStarRatingView.h"
#import "ReviewCell.h"

@interface DetailsViewController () <GMSMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, PhotoCellDelegate, NYTPhotosViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>
// Outlet Definitions //
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *placeView;
@property (weak, nonatomic) IBOutlet UILabel *checkInLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *wishlistButton;
@property (weak, nonatomic) IBOutlet UILabel *usersLabel;
@property (weak, nonatomic) IBOutlet UIView *userPicsView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *composeView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *reviewHeaderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLayoutHeight;

// Instance Properties //
@property (strong, nonatomic) GMSPlace *place;
@property (strong, nonatomic) Place *parsePlace;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) NSArray<PFUser *> *usersCheckedIn;
@property (strong, nonatomic) NSArray <Photo *> *photos;
@property (strong, nonatomic) NSArray <Review *> *reviews;
@property (nonatomic) CGFloat userRating;
@property (nonatomic) CGFloat tableViewHeight;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // create Parse Place from GMSPlace
    [Place checkGMSPlaceExists:self.place result:^(Place * _Nonnull newPlace) {
        self.parsePlace = newPlace;
        
        // change buttons if it's favorited/wishlisted
        [self.favoriteButton setSelected:[[PFUser currentUser].favorites containsObject:self.parsePlace]];
        [self.wishlistButton setSelected:[[PFUser currentUser].wishlist containsObject:self.parsePlace]];
        
        [self updateContent];
        
        //adjust height
        CGRect contentRect = CGRectZero;
        
        for (UIView *view in self.contentView.subviews) {
            contentRect = CGRectUnion(contentRect, view.frame);
        }
        self.scrollView.contentSize = contentRect.size;
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    // make sure the navigation bar is always visible
    [self.navigationController setNavigationBarHidden:NO];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateContent {
    self.placeNameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    [self updateCheckInLabel];
    [self initUsersCheckedIn];
    [self initWriteReview];
    [self initShowReviews];
    
    //configure photos collection view layout
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(72,72);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.collectionView.collectionViewLayout = layout;
    
    //configure photos view
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.photos = [NSArray new];
    [self fetchPlacePhotos];
    
    // update the map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.place.coordinate.latitude longitude:self.place.coordinate.longitude zoom:15];
    self.mapView = [GMSMapView mapWithFrame:self.placeView.bounds camera:camera];
    [self.placeView addSubview:self.mapView];
    self.mapView.delegate = self;
    
    // add a marker in the place
    GMSMarker *marker = [GMSMarker markerWithPosition:self.place.coordinate];
    marker.title = self.place.name;
    marker.map = self.mapView;
}

- (void)setPlace:(GMSPlace*)place {
    _place = place;
}

- (void)initUsersCheckedIn {
    [self.parsePlace getUsersCheckedInWithCompletion:^(NSArray<NSString *> * _Nullable users) {
        //only get users we're following
        [PFUser getFollowingWithinUserArray:users withCompletion:^(NSArray<NSString *> *followedUsers) {
            //init usersCheckedIn array
            self.usersCheckedIn = [[NSArray alloc] init];
            
            //move elements into a set to remove duplicates
            NSSet *followedUsersSet = [NSSet setWithArray:followedUsers];
            
            //convert objectId array to PFUser array
            [PFUser retrieveUsersWithIDs:[followedUsersSet allObjects] withCompletion:^(NSArray<PFUser *> *userObjects) {
                self.usersCheckedIn = userObjects;
                
                //display names of the first 2 users
                if (self.usersCheckedIn.count == 0) {
                    self.usersLabel.text = @"None of your friends have checked in here.";
                } else if (self.usersCheckedIn.count == 1) {
                    self.usersLabel.text = [NSString stringWithFormat:@"%@ has checked in here.",self.usersCheckedIn[0].displayName];
                } else if (self.usersCheckedIn.count == 2) {
                    self.usersLabel.text = [NSString stringWithFormat:@"%@ and %@ have checked in here.",self.usersCheckedIn[0].displayName, self.usersCheckedIn[1].displayName];
                } else {
                    //store number of other users checked in
                    long otherUsersCount = self.usersCheckedIn.count - 2;
                    self.usersLabel.text = [NSString stringWithFormat:@"%@, %@, and %ld others have checked in here.", self.usersCheckedIn[0].displayName, self.usersCheckedIn[1].displayName, otherUsersCount];
                }
                
                //display profile pics of first 5 users
                int i = 0;
                while(i < 5 && i < self.usersCheckedIn.count){
                    //create image view
                    UIImageView *userPicView = [[UIImageView alloc] initWithFrame:CGRectMake(i*48, 0, 40, 40)];
                    userPicView.backgroundColor = [UIColor colorNamed:@"VTR_GrayLabel"];
                    
                    //add profile picture
                    [ParseImageHelper setImageFromPFFile:self.usersCheckedIn[i].profilePicture forImageView:userPicView];
                    
                    //rounded corners
                    userPicView.layer.cornerRadius = userPicView.frame.size.width / 2;
                    userPicView.clipsToBounds = YES;
                    
                    //add image to subview
                    [self.userPicsView addSubview:userPicView];
                    i++;
                }
            }];
        }];
    }];
}

- (IBAction)didTapFavorite:(id)sender {
    // send it to parse
    if(self.favoriteButton.selected)
    {
        [[PFUser currentUser] removeFavorite:_place];
        
        // send notification
        [NCHelper notify:NTRemoveFavorite object:_place];
    }
    else
    {
        [[PFUser currentUser] addFavorite:_place];
        
        // send notification
        [NCHelper notify:NTAddFavorite object:_place];
    }
    
    // animate
    [UIView animateWithDuration:0.1 animations:^{
        self.favoriteButton.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.favoriteButton.transform = CGAffineTransformIdentity;
        }];
    }];
    
    // haptic feedback
    [[UIImpactFeedbackGenerator new] impactOccurred];
    
    // set the state
    [self.favoriteButton setSelected:!self.favoriteButton.selected];
}

- (IBAction)didTapWishlist:(id)sender {
    // send it to parse
    if(self.wishlistButton.selected)
    {
        [[PFUser currentUser] removeFromWishlist:_place];
        
        // send notification
        [NCHelper notify:NTRemoveFromWishlist object:_place];
    }
    else
    {
        [[PFUser currentUser] addToWishlist:_place];
        
        // send notification
        [NCHelper notify:NTAddToWishlist object:_place];
    }
    
    // animate
    [UIView animateWithDuration:0.1 animations:^{
        self.wishlistButton.transform = CGAffineTransformMakeScale(1.25, 1.25);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.wishlistButton.transform = CGAffineTransformIdentity;
        }];
    }];
    
    // haptic feedback
    [[UIImpactFeedbackGenerator new] impactOccurred];
    
    // set the state
    [self.wishlistButton setSelected:!self.wishlistButton.selected];
}

- (IBAction)didTapCheckIn:(id)sender {
    [self.parsePlace didCheckIn:PFUser.currentUser];
    [PFUser.currentUser addCheckIn:self.place.placeID withCompletion:^{
        [self updateCheckInLabel];
    }];
}

- (void)updateCheckInLabel {
    [PFUser.currentUser retrieveCheckInCountForPlaceID:self.place.placeID withCompletion:^(NSNumber *count) {
        self.checkInLabel.text = [NSString stringWithFormat: @"%@ check-ins",[count stringValue]];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"checkInsSegue"]) {
        CheckInsViewController *checkInsVC = [segue destinationViewController];
        checkInsVC.users = self.usersCheckedIn;
    }
}

#pragma mark - Photos

- (IBAction)didTapUploadPhoto:(id)sender {
    [AlertHelper showPhotoAlertWithoutCroppingFrom:self];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [ImageHelper resizeImageForParse:info[UIImagePickerControllerOriginalImage]];
    PFFile *photoFile = [ParseImageHelper getPFFileFromImage:image];
    Place *parsePlace = self.parsePlace;
    [parsePlace addPhoto:photoFile withCompletion:^{
        Photo *newPhoto = [[Photo alloc] initWithPFFile:photoFile userObjectId:PFUser.currentUser.objectId];
        NSMutableArray *mutablePhotos = [self.photos mutableCopy];
        [mutablePhotos insertObject:newPhoto atIndex:0];
        self.photos = [mutablePhotos copy];
        [self.collectionView reloadData];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) fetchPlacePhotos {
    [Relationships retrieveFollowingWithId:[PFUser currentUser].relationships.objectId WithCompletion:^(NSArray * _Nullable following) {
        [self.parsePlace retrievePhotosFromFollowing:following withCompletion:^(NSArray<Photo *> *photos) {
            self.photos = photos;
            [self.collectionView reloadData];
        }];
    }];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PhotoCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    cell.photo = self.photos[indexPath.item];
    cell.delegate = self;
    [cell configureCell];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (void)didTapPhoto:(Photo *)photo {
    NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:self.photos initialPhoto:photo];
    [self presentViewController:photosViewController animated:YES completion:nil];
}

#pragma mark - Reviews
- (void) initWriteReview {
    
    HCSStarRatingView *ratingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(72, 32, 100, 25)];
    ratingView.minimumValue = 0;
    ratingView.maximumValue = 5;
    [ratingView addTarget:self action:@selector(didChangeRating:) forControlEvents:UIControlEventValueChanged];
    
    [self.composeView addSubview:ratingView];
}

- (void) initShowReviews {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self fetchReviews];
}

- (void) reloadAndResize {
    [self.tableView reloadData];
    
    CGFloat tableViewHeight = self.reviewHeaderView.frame.size.height + self.composeView.frame.size.height;
    [self.tableView layoutIfNeeded];
    self.tableViewLayoutHeight.constant = self.tableView.contentSize.height + tableViewHeight;
    
    CGFloat height = 0;
    for (UIView *view in self.contentView.subviews) {
        height += view.frame.size.height;
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 2243);
}

- (void)didChangeRating:(id)sender {
    HCSStarRatingView *ratingView = (HCSStarRatingView *)sender;
    self.userRating = ratingView.value;
}

- (IBAction)didTapSubmit:(id)sender {
    Review *review = [Review object];
    review.user = PFUser.currentUser;
    review.content = self.reviewTextView.text;
    review.rating = (NSInteger) (floor(self.userRating));
    [self.parsePlace addReview:review withCompletion:^{
        //do something after uploading a review
    }];
}

- (void) fetchReviews {
    [Relationships retrieveFollowingWithId:[PFUser currentUser].relationships.objectId WithCompletion:^(NSArray * _Nullable following) {
        [self.parsePlace retrieveReviewsFromFollowing:following withCompletion:^(NSArray<Review *> *reviews) {
            self.reviews = reviews;
            [self reloadAndResize];
        }];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReviewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReviewCell" forIndexPath:indexPath];
    cell.review = self.reviews[indexPath.row];
    [cell configureCell];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reviews.count;
}

- (void) resizeTable {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)viewWillLayoutSubviews {
    
    CGFloat tableViewHeight = self.reviewHeaderView.frame.size.height + self.composeView.frame.size.height;
    
    for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
        tableViewHeight += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView layoutIfNeeded];
    self.tableViewLayoutHeight.constant = self.tableView.contentSize.height + tableViewHeight;
}

@end
