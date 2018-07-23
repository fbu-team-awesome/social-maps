//
//  LoginViewController.m
//  social-maps
//
//  Created by Britney Phan on 7/16/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

// Views for making it look pretty
@property (weak, nonatomic) IBOutlet UIView *usernameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUIStyles];
}

- (void)initUIStyles {
    // username textfield
    self.usernameView.layer.cornerRadius = 22;
    self.usernameView.clipsToBounds = YES;
    self.usernameView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.usernameView.layer.shadowOffset = CGSizeMake(0, 4);
    self.usernameView.layer.shadowRadius = 5;
    self.usernameView.layer.shadowOpacity = 0.2;
    self.usernameView.layer.masksToBounds = NO;
    
    // password textfield
    self.passwordView.layer.cornerRadius = 22;
    self.passwordView.clipsToBounds = YES;
    self.passwordView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.passwordView.layer.shadowOffset = CGSizeMake(0, 4);
    self.passwordView.layer.shadowRadius = 5;
    self.passwordView.layer.shadowOpacity = 0.2;
    self.passwordView.layer.masksToBounds = NO;
    
    // signup button
    self.signupButton.layer.cornerRadius = 22;
    self.signupButton.clipsToBounds = YES;
    self.signupButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.signupButton.layer.shadowOffset = CGSizeMake(0, 4);
    self.signupButton.layer.shadowRadius = 5;
    self.signupButton.layer.shadowOpacity = 0.2;
    self.signupButton.layer.masksToBounds = NO;
    
    // login button
    self.loginButton.layer.cornerRadius = 22;
    self.loginButton.clipsToBounds = YES;
    self.loginButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.loginButton.layer.shadowOffset = CGSizeMake(0, 4);
    self.loginButton.layer.shadowRadius = 5;
    self.loginButton.layer.shadowOpacity = 0.2;
    self.loginButton.layer.masksToBounds = NO;
}

- (IBAction)didTapLogin:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else {
            NSLog(@"User logged in successfully.");
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

@end
