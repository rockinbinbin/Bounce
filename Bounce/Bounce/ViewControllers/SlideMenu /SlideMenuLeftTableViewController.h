//
//  LeftMenuTVC.h
//  testProject
//
//  Created by artur on 2/14/14.
//  Copyright (c) 2014 artur. All rights reserved.
//

#import "AMSlideMenuLeftTableViewController.h"

@interface SlideMenuLeftTableViewController : AMSlideMenuLeftTableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate>


#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *MainViewWidth;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

#pragma mark - Properties
@property (strong, nonatomic) NSMutableArray *tableData;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCityLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userProfileImageView;
- (IBAction)signoutButtonClicked:(id)sender;
- (IBAction)changeImageButtonClicked:(id)sender;

@end
