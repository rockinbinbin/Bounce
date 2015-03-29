//
//  Utility.m
//  ChattingApp
//
//  Created by Shimaa Essam on 3/16/15.
//  Copyright (c) 2015 Shimaa Essam. All rights reserved.
//

#import "Utility.h"

@implementation Utility
{
    MBProgressHUD *progressHud;
}
static Utility *sharedUtility = nil;

+ (Utility*) getInstance{
    @try {
        @synchronized(self)
        {
            if (sharedUtility == nil)
            {
                sharedUtility = [[Utility alloc] init];
            }
        }
        return sharedUtility;
    }
    @catch (NSException *exception) {
    }
}

#pragma mark - progress hud
#pragma mark - Progress Hud Methods
- (void) showProgressHudWithMessage:(NSString*)message withView:(UIView *)view {
    [self hideProgressHud];
    progressHud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    progressHud.labelText = message;
}

- (void) hideProgressHud{
    if(progressHud && ![progressHud isHidden]){
        [progressHud hide:YES];
    }
}

#pragma mark - Check Internet Reachability
- (BOOL) checkReachabilityAndDisplayErrorMessage{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    BOOL ableToConnect = YES;
    
    if(status == NotReachable) {
        [self showAlertMessage:@"No Internet Connection"];
        ableToConnect = NO;
    }
    return ableToConnect;
}

#pragma mark - Show alert view
- (void)showAlertMessage:(NSString *)message
{
    NSLog(@"Method Name %@", [NSString stringWithUTF8String:__func__]);
    @try {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @""
                              message:message
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil
                              ];
        [alert show];
    }
    @catch (NSException *exception) {
    }
}

-(void) showAlertWithMessage:(NSString*) message andTitle:(NSString*)title{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}
@end
