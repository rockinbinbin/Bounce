//
//  CreateHomepoint.h
//  bounce
//
//  Created by Robin Mehta on 7/14/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"

@interface CreateHomepoint : UIViewController<ParseManagerUpdateGroupDelegate, ParseManagerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *groupNameTextField;
@property (nonatomic, strong) UIButton *addLocationButton;
@property (nonatomic, strong) UIButton *addPhotoButton;

@end