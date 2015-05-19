//
//  Terms_of_Use_ViewController.m
//  bounce
//
//  Created by Robin Mehta on 5/19/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "Terms_of_Use_ViewController.h"

@interface Terms_of_Use_ViewController ()

@end

@implementation Terms_of_Use_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self setBarButtonItemLeft:@"common_back_button"];
    self.navigationItem.title = @"Terms of Use";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self disableSlidePanGestureForLeftMenu];
}

#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName{
    
    UIImage *back = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:back withAction:@selector(backButtonClicked)];
}
-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}
-(void)backButtonClicked{
    
    AMSlideMenuMainViewController *mainVC = [self mainSlideMenu];
    UIViewController *rootVC = [[HomeScreenViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [mainVC.leftMenu openContentNavigationController:nvc];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
