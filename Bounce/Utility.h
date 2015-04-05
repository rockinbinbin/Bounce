//
//  Utility.h
//  ChattingApp
//
//  Created by Shimaa Essam on 3/16/15.
//  Copyright (c) 2015 Shimaa Essam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProgressHUD.h"
#import "Reachability.h"

@interface Utility : NSObject

+ (Utility*) getInstance;
// progress Hud
- (void) showProgressHudWithMessage:(NSString*)message withView:(UIView *)view;
- (void) showProgressHudWithMessage:(NSString*)message;
- (void) hideProgressHud;
// NetWork Connection
- (BOOL) checkReachabilityAndDisplayErrorMessage;
- (void)showAlertMessage:(NSString *)message;
-(void) showAlertWithMessage:(NSString*) message andTitle:(NSString*)title;
//
- (BOOL)isRequestValid:(NSDate *)craetedDate andTimeAllocated:(NSInteger) time;
// navigate to home screen
- (void) navigateToMainScreenFromNAvigationContorller:(UINavigationController *) navigationController;
// Create custom button
-(UIButton *)createCustomButton:(UIImage*) buttonImage;
@end
