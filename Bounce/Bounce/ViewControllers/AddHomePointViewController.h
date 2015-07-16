//
//  AddHomePointViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"

@interface AddHomePointViewController : UIViewController<ParseManagerUpdateGroupDelegate, ParseManagerDelegate, UITextFieldDelegate, ParseManagerLoadingGroupsDelegate>

@property (weak, nonatomic) UITableView *tableView;

-(void)navigateToCreateHomepointView;

@end
