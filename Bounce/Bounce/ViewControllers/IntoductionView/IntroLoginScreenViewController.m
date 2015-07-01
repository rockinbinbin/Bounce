//
//  LoginViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "IntroLoginScreenViewController.h"
#import "LoginScreenViewController.h"
#import "SignupScreenViewController.h"

@interface IntroLoginScreenViewController ()

@end

@implementation IntroLoginScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.currentIndexPageControl.backgroundColor = [UIColor clearColor];
    self.currentIndexPageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    self.view.backgroundColor = BounceRed;
    [self customiseButtonShadow:self.loginButton];
    [self customiseButtonShadow:self.registerButton];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(void) customiseButtonShadow:(UIButton*) btn{
    btn.backgroundColor = [UIColor colorWithRed:194.0/250.0 green:75.0/250.0 blue:75.0/250.0 alpha:1.0];
    btn.layer.cornerRadius = 8.0f;
    btn.layer.masksToBounds = NO;
    btn.layer.shadowColor = [UIColor blackColor].CGColor;
    btn.layer.shadowOpacity = 0.8;
    btn.layer.shadowRadius = 0;
    btn.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonClicked:(id)sender {
    LoginScreenViewController* loginScreenViewController = [[LoginScreenViewController alloc] initWithNibName:@"LoginScreenViewController" bundle:nil];
    [self.navigationController pushViewController:loginScreenViewController animated:YES];
}

- (IBAction)registerButtonClicked:(id)sender {
    SignupScreenViewController* signupScreenViewController = [[SignupScreenViewController alloc] initWithNibName:@"SignupScreenViewController" bundle:nil];
    [self.navigationController pushViewController:signupScreenViewController animated:YES];
}
@end
