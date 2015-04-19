//
//  HomePointSuccessfulCreationViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePointSuccessfulCreationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdHomePointLabel;
@property (weak, nonatomic) IBOutlet UIButton *sweetButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalDistanceBetweenFirstLabelAndIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftSpaceForLabel;
- (IBAction)sweetButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightSpaceForLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalDistanceBetweenLabels;

@end
