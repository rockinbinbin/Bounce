//
//  AddHomePointViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddHomePointViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *groupPrivacySegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *addLocationButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
- (IBAction)segmentedControlClicked:(id)sender;

@end
