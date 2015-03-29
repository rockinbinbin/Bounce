//
//  Utility.h
//  ChattingApp
//
//  Created by Shimaa Essam on 3/16/15.
//  Copyright (c) 2015 Shimaa Essam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "Reachability.h"
//#import "Constants.h"

@interface Utility : NSObject

+ (Utility*) getInstance;
- (void) showProgressHudWithMessage:(NSString*)message withView:(UIView *)view;
- (void) hideProgressHud;
- (BOOL) checkReachabilityAndDisplayErrorMessage;
- (void)showAlertMessage:(NSString *)message;
-(void) showAlertWithMessage:(NSString*) message andTitle:(NSString*)title;
@end
