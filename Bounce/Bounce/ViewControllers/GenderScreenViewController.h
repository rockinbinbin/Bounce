//
//  GenderScreenViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIDropDown.h"
#import <Parse/Parse.h>

@interface GenderScreenViewController : UIViewController <NIDropDownDelegate>

@property (weak, nonatomic) IBOutlet UIButton *gotItButton;
@property (weak, nonatomic) NIDropDown *dropDown;
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;
@property PFUser* currentUser;
@property NSString* gender;
@property (weak, nonatomic) IBOutlet UILabel *awesomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *weNeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *weUseLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightSpaceForLabels;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftSpaceForLabels;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceForGotItButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalDistanceBetweenGenderButtonAndLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *genderButtonYPosition;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalDistanceBetweenIconAndAboveLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weNeedLabelHeight;
- (IBAction)selectClicked:(id)sender;
- (IBAction)gotItButtonClicked:(id)sender;

-(void)rel;

@end
