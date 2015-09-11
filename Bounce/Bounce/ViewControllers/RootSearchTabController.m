//
//  RootSearchTabController.m
//  bounce
//
//  Created by Robin Mehta on 9/10/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "RootSearchTabController.h"
#import "AddHomePointViewController.h"
#import "SearchToAddGroups.h"
#import "Utility.h"
#import "CreateHomepoint.h"

@implementation RootSearchTabController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:20];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"Add Homepoint";
    [navLabel sizeToFit];
    
    
    UIButton *customButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"common_back_button"]];
    [customButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    
    UIBarButtonItem *createButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"createIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(createButtonClicked)];
    
    createButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = createButton;
    
    // Array to keep track of controllers in page menu
    NSMutableArray *controllerArray = [NSMutableArray array];
    
    // Create variables for all view controllers you want to put in the
    // page menu, initialize them, and add each to the controller array.
    // (Can be any UIViewController subclass)
    // Make sure the title property of all view controllers is set
    // Example:
    AddHomePointViewController *controller = [AddHomePointViewController new];
    controller.title = @"SEARCH BY ADDRESS";
    [controllerArray addObject:controller];
    
    SearchToAddGroups *controller2 = [SearchToAddGroups new];
    controller2.title = @"SEARCH BY NAME";
    [controllerArray addObject:controller2];
    
    // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
    // Example:
    NSDictionary *parameters = @{CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.1)
                                 };
    
    // Initialize page menu with controller array, frame, and optional parameters
    self.pagemenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    
    // Lastly add page menu as subview of base view controller view
    // or use pageMenu controller in you view hierachy as desired
    [self.view addSubview:self.pagemenu.view];
}

- (void) cancelButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)createButtonClicked {
    //    [[Utility getInstance] showProgressHudWithMessage:@"Loading"];
    //    [[ParseManager getInstance] setGetAllOtherGroupsDelegate:self];
    //    [[ParseManager getInstance] getAllOtherGroupsForCurrentUser];
    
    @try {
        CreateHomepoint *createhomepoint = [CreateHomepoint new];
        [self.navigationController pushViewController:createhomepoint animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}


@end
