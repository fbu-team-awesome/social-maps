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
#import "UIStylesHelper.h"
#import "MarkerManager.h"

@interface DetailsViewController () <GMSMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, PhotoCellDelegate, NYTPhotosViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
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
@property (weak, nonatomic) IBOutlet UIView *composeView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *overallRatingView;
@property (weak, nonatomic) IBOutlet UIView *composeRatingView;
@property (weak, nonatomic) IBOutlet UIView *submitButtonView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *overallRatingLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingsCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkInButton;
@property (weak, nonatomic) IBOutlet UIView *checkInButtonView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *composeBottomSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userPicsLayoutHeight;
@property (weak, nonatomic) IBOutlet UIView *checkedInContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photosLayoutHeight;
@property (weak, nonatomic) IBOutlet UILabel *placeTypeLabel;

// Instance Properties //
@property (strong, nonatomic) GMSPlace *place;
@property (strong, nonatomic) Place *parsePlace;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) NSArray<PFUser *> *usersCheckedIn;
@property (strong, nonatomic) NSArray <Photo *> *photos;
@property (strong, nonatomic) NSArray <Review *> *reviews;
@property (nonatomic) CGFloat userRating;
@property (nonatomic) CGFloat tableViewHeight;
@property (nonatomic) double overallRating;
@property (nonatomic) CGFloat keyboardHeight;

@end

@implementation DetailsViewController

#pragma mark - Init

- (void)viewDidLoad {
    [super viewDidLoad];
    // create Parse Place from GMSPlace
    [Place checkGMSPlaceExists:self.place result:^(Place * _Nonnull newPlace) {
        self.parsePlace = newPlace;
        
        // change buttons if it's favorited/wishlisted
        [self.favoriteButton setSelected:[[PFUser currentUser].favorites containsObject:self.parsePlace]];
        [self.wishlistButton setSelected:[[PFUser currentUser].wishlist containsObject:self.parsePlace]];
        [self updateContent];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    // make sure the navigation bar is always visible
    [self.navigationController setNavigationBarHidden:NO];
    
    self.placeNameLabel.text = self.place.name;
    self.addressLabel.text = self.place.formattedAddress;
    [UIStylesHelper addRoundedCornersToView:self.checkInButton];
    [UIStylesHelper addShadowToView:self.checkInButton withOffset:CGSizeMake(0, 1) withRadius:2 withOpacity:0.16];
    [UIStylesHelper addGradientToView:self.checkInButton];
    
    [self updateCheckInLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateContent {
    
    [self initUsersCheckedIn];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
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
    
    
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.tableView.tableHeaderView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    [self.tableView.tableHeaderView setFrame:CGRectMake(0, 0, contentRect.size.width, contentRect.size.height)];
    [self.tableView layoutIfNeeded];
    
    // update the map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.place.coordinate.latitude longitude:self.place.coordinate.longitude zoom:15];
    self.mapView = [GMSMapView mapWithFrame:self.placeView.bounds camera:camera];
    [self.placeView addSubview:self.mapView];
    self.mapView.delegate = self;
    
    // add a marker in the place
    GMSMarker *marker = [GMSMarker markerWithPosition:self.place.coordinate];
    marker.icon = [UIImage imageNamed:@"temp_marker_icon"];
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
                    CGFloat height = self.userPicsView.frame.size.height;
                    self.userPicsView.hidden = YES;
                    CGRect frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.tableHeaderView.frame.size.height - height);
                    [self.tableView.tableHeaderView setFrame:frame];
                    [self.tableView layoutIfNeeded];
                } else {
                    if (self.usersCheckedIn.count == 1) {
                        self.usersLabel.text = [NSString stringWithFormat:@"%@ has checked in here.",self.usersCheckedIn[0].displayName];
                    } else if (self.usersCheckedIn.count == 2) {
                        self.usersLabel.text = [NSString stringWithFormat:@"%@ and %@ have checked in here.",self.usersCheckedIn[0].displayName, self.usersCheckedIn[1].displayName];
                    } else {
                        //store number of other users checked in
                        long otherUsersCount = self.usersCheckedIn.count - 2;
                        self.usersLabel.text = [NSString stringWithFormat:@"%@, %@, and %ld others have checked in here.", self.usersCheckedIn[0].displayName, self.usersCheckedIn[1].displayName, otherUsersCount];
                    }
                    if (self.userPicsLayoutHeight.constant == 0) {
                        self.userPicsLayoutHeight.constant = 40;
                        CGRect frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.tableHeaderView.frame.size.height + 40);
                        CGRect frame2 = CGRectMake(0, self.tableView.tableHeaderView.frame.size.height + 40, self.tableView.frame.size.width, self.tableView.tableFooterView.frame.size.height);
                        
                        [self.tableView.tableHeaderView setFrame:frame];
                        [self.tableView.tableFooterView setFrame:frame2];
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
                        [self.tableView reloadData];
                        [self.tableView layoutIfNeeded];
                    }
                    
                    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCheckedInUsers:)];
                    [self.checkedInContainer setUserInteractionEnabled:YES];
                    [self.checkedInContainer addGestureRecognizer:tapGR];
                }
                
                //display profile pics of first 5 users
            }];
        }];
    }];
}

-(void) didTapCheckedInUsers:(id)sender {
    [self performSegueWithIdentifier:@"checkInsSegue" sender:nil];
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
        [UIStylesHelper animateTapOnView:self.checkInButton];
    }];
}

- (void)updateCheckInLabel {
    [PFUser.currentUser retrieveCheckInCountForPlaceID:self.place.placeID withCompletion:^(NSNumber *count) {
        if ([count isEqualToNumber: [NSNumber numberWithInteger:1]]) {
            self.checkInLabel.text =  @"You've checked in once before.";
        } else if ([count isEqualToNumber: [NSNumber numberWithInteger:0]]) {
            self.checkInLabel.text =  @"You've never checked in here before.";
        } else {
            self.checkInLabel.text = [NSString stringWithFormat: @"You've checked in %@ times.",[count stringValue]];
        }
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
        if (self.photosLayoutHeight.constant == 0) {
            [self.collectionView setHidden: NO];
            self.photosLayoutHeight.constant = 72;
            CGRect frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.tableHeaderView.frame.size.height + 72);
            CGRect frame2 = CGRectMake(0, self.tableView.tableHeaderView.frame.size.height + 72, self.tableView.frame.size.width, self.tableView.tableFooterView.frame.size.height);
            
            [self.tableView.tableHeaderView setFrame:frame];
            [self.tableView.tableFooterView setFrame:frame2];

            
        }
        [self.collectionView reloadData];
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        [UITableView animateWithDuration:0.3 animations:^{
            self.tableView.contentInset = UIEdgeInsetsZero;
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
        }];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) fetchPlacePhotos {
    [Relationships retrieveFollowingWithId:[PFUser currentUser].relationships.objectId WithCompletion:^(NSArray * _Nullable following) {
        [self.parsePlace retrievePhotosFromFollowing:following withCompletion:^(NSArray<Photo *> *photos) {
            self.photos = photos;
            if (self.photos.count == 0) {
                [self.collectionView setHidden:YES];
                [self.tableView layoutIfNeeded];
            } else {
                if (self.photosLayoutHeight.constant == 0) {
                    [self.collectionView setHidden: NO];
                    self.photosLayoutHeight.constant = 72;
                    CGRect frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.tableHeaderView.frame.size.height + 72);
                    [self.tableView.tableHeaderView setFrame:frame];
                    [self.tableView layoutIfNeeded];
                }
                [self.collectionView reloadData];
            }
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
    HCSStarRatingView *ratingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(0, 0, 95, 13)];
    ratingView.minimumValue = 0;
    ratingView.maximumValue = 5;
    ratingView.starBorderWidth= 0;
    ratingView.filledStarImage = [UIImage imageNamed:@"star_filled"] ;
    ratingView.emptyStarImage = [UIImage imageNamed:@"star_unfilled"];
    [ratingView addTarget:self action:@selector(didChangeRating:) forControlEvents:UIControlEventValueChanged];
    [self.composeRatingView addSubview:ratingView];
    
    self.reviewTextView.layer.cornerRadius = 8;
    self.reviewTextView.layer.borderColor = [UIColor colorNamed:@"VTR_Borders"].CGColor;
    self.reviewTextView.layer.borderWidth = 1;
    self.reviewTextView.delegate = self;
    
    [UIStylesHelper addRoundedCornersToView:self.submitButton];
    [UIStylesHelper addShadowToView:self.submitButton withOffset:CGSizeMake(0, 1) withRadius:2 withOpacity:0.16];
    [UIStylesHelper addGradientToView:self.submitButton];
}

-(void)keyboardWillAppear:(NSNotification *)notification {
    NSDictionary *info  = notification.userInfo;
    NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardFrame.size.height-self.tabBarController.tabBar.frame.size.height), 0.0);
    [UITableView animateWithDuration:0.3 animations:^{
        
        [self.tableView setContentInset: contentInsets];
        self.tableView.scrollIndicatorInsets = contentInsets;
        [self.tableView scrollRectToVisible:[self.tableView convertRect:self.tableView.tableFooterView.bounds fromView:self.tableView.tableFooterView] animated:NO];
    }];
}

- (IBAction)didTapView:(id)sender {
    [self.reviewTextView endEditing:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UITableView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
}

- (void) initShowReviews {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.reviews = [[NSArray alloc] init];
    [self fetchReviews];
}

- (void) reloadAndUpdateRating {
    [self.tableView reloadData];
    [self updatePlaceRating];
}

- (void)didChangeRating:(id)sender {
    HCSStarRatingView *ratingView = (HCSStarRatingView *)sender;
    self.userRating = ratingView.value;
}

- (IBAction)didTapSubmit:(id)sender {
    Review *review = [Review object];
    review.user = PFUser.currentUser;
    review.content = self.reviewTextView.text;
    review.rating = (floor(self.userRating));
    [review saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.parsePlace addReview:review.objectId withCompletion:^{
            self.reviews = [self.reviews arrayByAddingObject:review];
            self.reviewTextView.text = @"";
            //replace rating with an empty one
            for (UIView *view in [self.composeRatingView subviews])
            {
                [view removeFromSuperview];
            }
            HCSStarRatingView *ratingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(0, 0, 95, 13)];
            ratingView.minimumValue = 0;
            ratingView.maximumValue = 5;
            ratingView.starBorderWidth= 0;
            ratingView.filledStarImage = [UIImage imageNamed:@"star_filled"] ;
            ratingView.emptyStarImage = [UIImage imageNamed:@"star_unfilled"];
            ratingView.value = 0;
            ratingView.allowsHalfStars = NO;
            [self.composeRatingView addSubview:ratingView];
            [self.reviewTextView endEditing:YES];
            [self reloadAndUpdateRating];
        }];
    }];
}

- (void) fetchReviews {
    [PFUser.currentUser retrieveRelationshipWithCompletion:^(Relationships *relationships)  {
        [Relationships retrieveFollowingWithId:relationships.objectId WithCompletion:^(NSArray * _Nullable following) {
            NSLog(@"Fetched all following");
            [self.parsePlace retrieveReviewsFromFollowing:following withCompletion:^(NSArray<NSString *> *reviews) {
                NSLog(@"Fetched all reviews");
                [Review retrieveReviewsWithIDs:reviews withCompletion:^(NSArray<Review *> *newReviews) {
                    self.reviews = newReviews;
                    [self reloadAndUpdateRating];
                }];
            }];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void) updatePlaceRating {
    double newRatingSum = 0;
    for (Review *review in self.reviews) {
        newRatingSum += review.rating;
    }
    if (self.reviews.count > 0) {
        self.overallRating = newRatingSum / self.reviews.count;
        for (UIView *view in [self.overallRatingView subviews])
        {
            [view removeFromSuperview];
        }
        HCSStarRatingView *ratingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(0, 0, 95, 13)];
        ratingView.minimumValue = 0;
        ratingView.maximumValue = 5;
        ratingView.starBorderWidth= 0;
        ratingView.filledStarImage = [UIImage imageNamed:@"star_filled"] ;
        ratingView.emptyStarImage = [UIImage imageNamed:@"star_unfilled"];
        ratingView.value = (CGFloat) self.overallRating;
        ratingView.allowsHalfStars = YES;
        [ratingView setEnabled:NO];
        [self.overallRatingView addSubview:ratingView];
        NSNumber *ratingNumber = [NSNumber numberWithDouble:self.overallRating];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.roundingIncrement = [NSNumber numberWithDouble:0.01];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        [self.overallRatingLabel setText:[NSString stringWithFormat:@"%@ stars",[formatter stringFromNumber:ratingNumber]]];

    }
    [self.ratingsCountLabel setText:[NSString stringWithFormat:@"%lu ratings",self.reviews.count]];
}


@end
