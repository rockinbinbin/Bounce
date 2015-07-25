//
//  HomePointSuccessfulCreationViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "HomePointSuccessfulCreationViewController.h"
#import "AppConstant.h"
#import "GroupsListViewController.h"
#import "UIViewController+AMSlideMenu.h"

@interface HomePointSuccessfulCreationViewController ()

@end

@implementation HomePointSuccessfulCreationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    self.view.backgroundColor = BounceRed;
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self disableSlidePanGestureForLeftMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)sweetButtonClicked {
    GroupsListViewController* groupsListViewController = [GroupsListViewController new];
    [self.navigationController pushViewController:groupsListViewController animated:YES];
}
@end
