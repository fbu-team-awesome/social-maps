//
//  SignUpViewController.m
//  social-maps
//
//  Created by César Francisco Barraza on 7/17/18.
//  Copyright © 2018 Bevin Benson. All rights reserved.
//

#import <Parse/Parse.h>
#import "PFUser+ExtendedUser.h"
#import "SignUpViewController.h"

@interface SignUpViewController ()
// Outlet Definitions //
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *displayNameField;
@property (weak, nonatomic) IBOutlet UITextField *hometownField;
@property (weak, nonatomic) IBOutlet UITextField *bioField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.profileImage.layer.shadowOffset = CGSizeZero;
    self.profileImage.layer.shadowRadius = 5;
    self.profileImage.layer.shadowOpacity = 0.2;
    self.profileImage.layer.masksToBounds = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)confirmClicked:(id)sender {
    NSString* username = self.usernameField.text;
    NSString* password = self.passwordField.text;
    NSString* displayName = self.displayNameField.text;
    NSString* hometown = self.hometownField.text;
    NSString* bio = self.bioField.text;
    NSString* email = self.emailField.text;
    
    // validate text fields
    if([username length] <= 0 || [password length] <= 0 || [displayName length] <= 0 || [hometown length] <= 0 || [bio length] <= 0 || [email length] <= 0)
    {
        [self showAlertWithTitle:@"Sign Up Error" message:@"Please fill all the fields."];
        return;
    }
    
    // we have all the info
    PFUser *newUser = [PFUser user];
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    newUser.email = email;
    newUser.displayName = displayName;
    newUser.hometown = hometown;
    newUser.bio = bio;
    newUser.favorites = [NSMutableArray new];
    newUser.wishlist = [NSMutableArray new];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully.");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (IBAction)cancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
