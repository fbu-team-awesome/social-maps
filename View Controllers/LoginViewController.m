//
//  LoginViewController.m
//  social-maps
//
//  Created by Britney Phan on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "LoginViewController.h"
#import "AlertHelper.h"
#import "UIStylesHelper.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

// Views for making it look pretty
@property (weak, nonatomic) IBOutlet UIView *usernameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUIStyles];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.usernameField becomeFirstResponder];
}

- (void)initUIStyles {
    [UIStylesHelper addRoundedCornersToView:self.usernameView];
    [UIStylesHelper addShadowToView:self.usernameView withOffset:CGSizeMake(0, 1.2) withRadius:1.5 withOpacity:0.2];
    [UIStylesHelper addRoundedCornersToView:self.passwordView];
    [UIStylesHelper addShadowToView:self.passwordView withOffset:CGSizeMake(0, 1.2) withRadius:1.5 withOpacity:0.2];
    [UIStylesHelper addRoundedCornersToView:self.loginButton];
    [UIStylesHelper addShadowToView:self.loginButton withOffset:CGSizeMake(0, 2) withRadius:2 withOpacity:0.2];
    [UIStylesHelper addGradientToView:self.loginButton];
}

- (IBAction)didTapLogin:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (error != nil) {
            [AlertHelper showAlertWithTitle:@"Login Error:" message:error.localizedDescription sender:self];
        } else {
            [[PFUser currentUser] retrieveRelationshipWithCompletion:^(Relationships *relationship) {
                [PFUser currentUser].relationships = relationship;
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            }];
        }
    }];
}

- (IBAction)didTapSignUp:(id)sender {
    [self performSegueWithIdentifier:@"signUpSegue" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
