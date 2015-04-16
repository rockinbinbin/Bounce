//
//  GenderScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "GenderScreenViewController.h"
#import "HomeScreenViewController.h"
#import "AppConstant.h"
#import "Utility.h"
#import "ProgressHUD.h"
#import "UIViewController+AMSlideMenu.h"

@interface GenderScreenViewController ()

@end

@implementation GenderScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    if (IS_IPAD) {
        self.awesomeLabel.font = [self.awesomeLabel.font fontWithSize:60];
        self.weNeedLabel.font = [self.weNeedLabel.font fontWithSize:30];
        self.weUseLabel.font = [self.weUseLabel.font fontWithSize:30];
        self.rightSpaceForLabels.constant = 60;
        self.leftSpaceForLabels .constant = 60;
        self.bottomSpaceForGotItButton.constant = 60;
        self.verticalDistanceBetweenGenderButtonAndLabel.constant = 120;
        self.genderButtonYPosition.constant = -100;
    }
    if (IS_IPHONE4) {
        self.bottomSpaceForGotItButton.constant = 20;
        self.verticalDistanceBetweenIconAndAboveLabel.constant = 10;
        self.verticalDistanceBetweenGenderButtonAndLabel.constant = 20;
        self.weNeedLabelHeight.constant = 50;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingNotification:) name:@"SelectedStringNotification" object:nil];

    // Do any additional setup after loading the view from its nib.
    _btnSelect.backgroundColor = [UIColor whiteColor];
    self.gotItButton.backgroundColor = LIGHT_BLUE_COLOR;
    self.view.backgroundColor = DEFAULT_COLOR;
    
    UIImageView *downArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_down_arrow"]];
    downArrow.contentMode = UIViewContentModeScaleToFill;
    downArrow.frame = CGRectMake(160, 10, 20, 20);
    downArrow.contentMode=UIViewContentModeScaleAspectFill;
    [self.btnSelect addSubview:downArrow];
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [self disableSlidePanGestureForLeftMenu];
}

- (void) incomingNotification:(NSNotification *)notification{
    NSString *genderSent = [notification object];
    self.gender = genderSent;
}

- (void)viewDidUnload {
    _btnSelect = nil;
    [self setBtnSelect:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)selectClicked:(id)sender {
    NSArray * arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@"Male", @"Female",nil];
    if(_dropDown == nil) {
        CGFloat f = 80;
        _dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :nil :@"down"];
        _dropDown.delegate = self;
    }
    else {
        [_dropDown hideDropDown:sender];
        [self rel];
    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    [self rel];
}

- (IBAction)gotItButtonClicked:(id)sender {
    PFUser* signUpUser = self.currentUser;
    if (!(self.gender == nil || self.gender.length == 0)) {
        signUpUser[@"Gender"] = self.gender;
        [signUpUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Signup is performed successfully");
                [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                [[PFInstallation currentInstallation] setObject:@"true" forKey:@"State"];
                [[PFInstallation currentInstallation] saveEventually];
                //                        [self.navigationController popToRootViewControllerAnimated:YES];
                [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome %@!", signUpUser[PF_USER_FULLNAME]]];
                [self dismissViewControllerAnimated:YES completion:nil];
                
                HomeScreenViewController* homeScreenViewController = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
                [self.navigationController pushViewController:homeScreenViewController animated:YES];

            } else {
                [[Utility getInstance] showAlertWithMessage:[error.userInfo objectForKey:@"error"] andTitle:@"Sorry!"];
            }
        }];
    }
    else{
        [[Utility getInstance] showAlertWithMessage:@"Make sure you selected the gender!" andTitle:@"Oops!"];
    }

}

-(void)rel{
    //    [dropDown release];
    _dropDown = nil;
}


@end
