//
//  AddHomePointViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"

@interface AddHomePointViewController : UIViewController<ParseManagerUpdateGroupDelegate, ParseManagerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *groupPrivacySegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *addLocationButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalDistanceBetweenTableAndItsBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceToGroupName;
- (IBAction)segmentedControlClicked:(id)sender;
- (IBAction)addLocationButtonClicked:(id)sender;

@end
