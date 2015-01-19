//
//  GroupsPlusViewController.m
//  hobble.1.1
//
//  Created by Robin Mehta on 1/19/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "GroupsPlusViewController.h"

@interface GroupsPlusViewController ()

@end

@implementation GroupsPlusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // background
    self.title = @"Add Groups";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Register Button
    self.CreateGroupButton.buttonColor = [UIColor redColor];
    self.CreateGroupButton.shadowColor = [UIColor purpleColor];
    self.CreateGroupButton.shadowHeight = 3.0f;
    self.CreateGroupButton.cornerRadius = 6.0f;
    self.CreateGroupButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.CreateGroupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.CreateGroupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    // Register Button
    self.SearchGroupsButton.buttonColor = [UIColor redColor];
    self.SearchGroupsButton.shadowColor = [UIColor purpleColor];
    self.SearchGroupsButton.shadowHeight = 3.0f;
    self.SearchGroupsButton.cornerRadius = 6.0f;
    self.SearchGroupsButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.SearchGroupsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.SearchGroupsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)unwind:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
