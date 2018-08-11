//
//  SearchBarView.m
//  social-maps
//
//  Created by Bevin Benson on 8/10/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "SearchBarView.h"
#import "SearchBarTextField.h"


@interface SearchBarView ()

@property (strong, nonatomic) UIView *searchView;
@property (strong, nonatomic) UIView *searchBoxView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) SearchBarTextField *searchField;
@property (strong, nonatomic) GMSAutocompleteFetcher *fetcher;

@end

@implementation SearchBarView
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    [self createSearchBar];
    return self;
}

- (void)createSearchBar {
    
    self.searchView = [[UIView alloc] initWithFrame:self.frame];
    [self.searchView setBackgroundColor:[UIColor colorNamed:@"VTR_Background"]];
    [self addSubview:self.searchView];
    
    self.searchBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, (self.frame.size.width*7)/8, 40)];
    self.searchBoxView.center = CGPointMake(self.searchView.frame.size.width/2, self.searchBoxView.center.y);
    self.searchBoxView.layer.masksToBounds = NO;
    self.searchBoxView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.searchBoxView.layer.shadowOffset = CGSizeMake(0, 1);
    self.searchBoxView.layer.shadowRadius = 1;
    self.searchBoxView.layer.shadowOpacity = 0.15;
    self.searchBoxView.layer.cornerRadius = 12;
    self.searchBoxView.layer.borderColor = [UIColor clearColor].CGColor;
    [self.searchBoxView setBackgroundColor:[UIColor whiteColor]];
    [self.searchView addSubview:self.searchBoxView];
    
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.searchBoxView.frame.origin.x, self.searchBoxView.frame.origin.y, 15, 15)];
    searchIcon.center = CGPointMake(searchIcon.center.x - 10, self.searchBoxView.frame.size.height/2);
    searchIcon.image = [UIImage imageNamed:@"search_icon_gray"];
    [self.searchBoxView addSubview:searchIcon];
    
    self.searchField = [[SearchBarTextField alloc] initWithFrame:CGRectMake(self.searchBoxView.frame.origin.x + 15, self.searchBoxView.frame.origin.y, self.searchBoxView.frame.size.width*5/6, self.searchBoxView.frame.size.height/2)];
    self.searchField.center = CGPointMake(self.searchField.center.x, self.searchBoxView.frame.size.height/2);
    [self.searchField setBackgroundColor:[UIColor whiteColor]];
    [self.searchField setTintColor:[UIColor colorNamed:@"VTR_GrayLabel"]];
    [self.searchField setFont:[UIFont fontWithName:@"Avenir Next" size:16]];
    [self.searchField setTextColor:[UIColor colorNamed:@"VTR_GrayLabel"]];
    [self.searchField setPlaceholder:@"Search"];
    [self.searchField addTarget:self action:@selector(textWasEdited) forControlEvents:UIControlEventEditingChanged];
    [self.searchField addTarget:self.delegate action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.searchBoxView addSubview:self.searchField];
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.searchBoxView.frame.origin.x + (self.frame.size.width*7)/10 + 10, self.frame.origin.y, 60, 40)];
    self.cancelButton.center = CGPointMake(self.cancelButton.center.x, self.searchBoxView.center.y);
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorNamed:@"VTR_BlackLabel"] forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont fontWithName:@"Avenir Next" size:14]];
    [self.cancelButton setHidden:YES];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton addTarget:self.delegate action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchView addSubview:self.cancelButton];

}

- (void)showCancel {
    [self.cancelButton setHidden:NO];
    
    [self.searchBoxView setFrame:CGRectMake(self.searchBoxView.frame.origin.x, self.searchBoxView.frame.origin.y, (self.frame.size.width*7)/10, 40)];
    [self.searchField setFrame:CGRectMake(self.searchBoxView.frame.origin.x + 15, self.searchBoxView.frame.origin.y, self.searchBoxView.frame.size.width*5/6, self.searchBoxView.frame.size.height/2)];
    self.searchField.center = CGPointMake(self.searchField.center.x, self.searchBoxView.frame.size.height/2);
}

- (void)hideCancel {
    [self.cancelButton setHidden:YES];
    
    [self.searchBoxView setFrame:CGRectMake(0, self.searchView.frame.origin.y + 30, (self.frame.size.width*7)/8, 40)];
    self.searchBoxView.center = CGPointMake(self.searchView.frame.size.width/2, self.searchBoxView.center.y);
    [self.searchField setFrame:CGRectMake(self.searchBoxView.frame.origin.x + 15, self.searchBoxView.frame.origin.y, self.searchBoxView.frame.size.width*5/6, self.searchBoxView.frame.size.height/2)];
    self.searchField.center = CGPointMake(self.searchField.center.x, self.searchBoxView.frame.size.height/2);
}

- (void)cancelButtonClicked {
    [self hideCancel];
    [self.searchField setText:@""];[self hideCancel];
    [self.searchField setText:@""];
}

- (void)textWasEdited {
    NSString *searchText = self.searchField.text;
    if (searchText.length == 0) {
        [self hideCancel];
        [self.searchBoxView setHidden:NO];
        // [self.view endEditing:YES];
    }
    else if (searchText.length == 1) {
        [self showCancel];
    }
}

- (void)setPlaceholderText:(NSString *)placeholderText {
    [self.searchField setPlaceholder:placeholderText];
}
@end
