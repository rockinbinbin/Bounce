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

    [self justifyTextInLabel:self.firstLabel];
    [self justifyTextInLabel:self.secondLabel];

    self.view.backgroundColor = DEFAULT_COLOR;
    self.sweetButton.backgroundColor = LIGHT_BLUE_COLOR;
}
- (void) viewWillAppear:(BOOL)animated
{
    [self disableSlidePanGestureForLeftMenu];
}
-(void) justifyTextInLabel:(UILabel*) label{
    NSMutableParagraphStyle *paragraphStyles = [[NSMutableParagraphStyle alloc] init];
    paragraphStyles.alignment = NSTextAlignmentJustified;
    paragraphStyles.firstLineHeadIndent = 1.0;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyles};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString: label.text attributes: attributes];
    label.attributedText = attributedString;
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

- (IBAction)sweetButtonClicked:(id)sender {
    GroupsListViewController* groupsListViewController = [[GroupsListViewController alloc] initWithNibName:@"GroupsListViewController" bundle:nil];
    [self.navigationController pushViewController:groupsListViewController animated:YES];
}
@end
