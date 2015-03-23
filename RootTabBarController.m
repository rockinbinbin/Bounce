//
//  RootTabBarController.m
//  bounce
//
//  Created by Robin Mehta on 3/20/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "RootTabBarController.h"
#import "utilities.h"
#import <Parse/Parse.h>
#import "UsersListViewController.h"
#import "GroupsListViewController.h"

@interface RootTabBarController ()

@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UsersListViewController* userListViewController = [[UsersListViewController alloc] init];
//    GroupsListViewController* groupListViewController = [[GroupsListViewController alloc] init];

    NSMutableArray * controller = [NSMutableArray arrayWithArray: self.viewControllers] ;
    
//    NSArray * items = self.tabBar.items;
//    [[items objectAtIndex:1] setTitle:@"Messages"];
//    self.tabBar.items = items;
//    UITabBarItem *item2 = [self.tabBar.items objectAtIndex:1] ;
//    item2.title = @"Messages";
//    [[self.tabBar.items objectAtIndex:1] setTitle:@"Messages"];
//    UITabBarItem *item3 = [self.tabBar.items objectAtIndex:2];
//    item3.title = @"Groups";
    
//    
    UINavigationController *useresNavigationBarController = [[UINavigationController alloc] initWithRootViewController:userListViewController];
//    UINavigationController *groupsNavigationBarController = [[UINavigationController alloc] initWithRootViewController:groupListViewController];

    [controller replaceObjectAtIndex:1 withObject:useresNavigationBarController];
//    [controller replaceObjectAtIndex:2 withObject:groupsNavigationBarController];

    self.viewControllers = [NSArray arrayWithArray:controller];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    NSLog(@"Selected");
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
