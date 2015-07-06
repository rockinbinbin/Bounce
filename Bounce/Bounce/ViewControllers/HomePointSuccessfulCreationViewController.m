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

- (void)updateViewConstraints {
    [super updateViewConstraints];
    if (IS_IPAD) {
        self.createdHomePointLabel.font = [self.createdHomePointLabel.font fontWithSize:40];
        self.firstLabel.font = [self.firstLabel.font fontWithSize:30];
        self.secondLabel.font = [self.secondLabel.font fontWithSize:30];
        self.iconWidth.constant = 180;
        self.iconHeight.constant = 180;
        self.leftSpaceForLabel.constant = 60;
        self.rightSpaceForLabel.constant = 60;
        self.verticalDistanceBetweenFirstLabelAndIcon.constant = 60;
        self.verticalDistanceBetweenLabels.constant = 60;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    [self justifyTextInLabel:self.firstLabel];
    [self justifyTextInLabel:self.secondLabel];

    self.view.backgroundColor = BounceRed;
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

- (IBAction)sweetButtonClicked:(id)sender {
    GroupsListViewController* groupsListViewController = [[GroupsListViewController alloc] initWithNibName:@"GroupsListViewController" bundle:nil];
    [self.navigationController pushViewController:groupsListViewController animated:YES];
}
@end
