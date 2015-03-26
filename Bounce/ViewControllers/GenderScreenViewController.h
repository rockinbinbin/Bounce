//
//  GenderScreenViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIDropDown.h"

@interface GenderScreenViewController : UIViewController <NIDropDownDelegate>

@property (weak, nonatomic) IBOutlet UIButton *gotItButton;
@property (weak, nonatomic) NIDropDown *dropDown;
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;
- (IBAction)selectClicked:(id)sender;

-(void)rel;

@end
