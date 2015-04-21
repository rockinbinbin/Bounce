//
//  MainViewController.m
//  bounce
//
//  Created by Shimaa Essam on 3/31/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "SlideMenuLeftTableViewController.h"
#import "Constants.h"
#import "ParseManager.h"
@interface SlideMenuViewController ()

@end

@implementation SlideMenuViewController

- (void)viewDidLoad {
    self.leftMenu = [[SlideMenuLeftTableViewController alloc] initWithNibName:@"SlideMenuLeftTableViewController" bundle:nil];
    self.rightMenu = nil;
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    AMSlideMenuState oldState = [self menuState];
    [super viewWillAppear:animated];
    if (oldState == AMSlideMenuLeftOpened) {
        [self openLeftMenu];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Overriding methods
- (void)configureLeftMenuButton:(UIButton *)button
{
    UIImage* menuIcon = [UIImage imageNamed:@"nav_bar_profile_menu_icon"];
    CGRect frame = button.frame;
    frame.origin = (CGPoint){0,0};
    frame.size = menuIcon.size;
    button.frame = frame;
    
    [button setImage:menuIcon forState:UIControlStateNormal];
}

- (BOOL)deepnessForLeftMenu
{
    return NO;
}

- (CGFloat)maxDarknessWhileLeftMenu
{
    return 0.3f;
}
- (void)closeLeftMenu
{
    [self closeLeftMenuAnimated:YES];
}
- (void)openLeftMenu
{
    NSLog(@"openLeftMenu");
    [[ParseManager getInstance] getNumberOfValidRequests];
    [self openLeftMenuAnimated:YES];
}
- (CGFloat)leftMenuWidth
{
    return SIDE_MENU_WIDTH;
}

- (NSIndexPath *)initialIndexPathForLeftMenu
{
    return [NSIndexPath indexPathForRow:self.initialIndex inSection:0];

}
@end
