//
//  ChatViewController.m
//  bounce
//
//  Created by Shimaa Essam on 3/29/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "CustomChatViewController.h"
#import "Utility.h"
#import "ParseManager.h"
#import "Constants.h"
#import "UIViewController+AMSlideMenu.h"

@interface CustomChatViewController ()

@end

@implementation CustomChatViewController
{
    UIAlertView *requestTimeOverAlert;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.barTintColor = BounceRed;
    self.navigationController.navigationBar.translucent = NO;
    UIButton *customButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"common_back_button"]];
    [customButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self disableSlidePanGestureForLeftMenu];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMessages{
    // is Request still valid
    // retreive requet
    // validate request end
    // if request still valid
    //    self.currentRequest = [[ParseManager getInstance] retrieveRequest:self.currentRequest];
    [super loadMessages];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.currentRequest = [[ParseManager getInstance] retrieveRequestUpdate:self.groupId];
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL requestEnded = [[self.currentRequest objectForKey:PF_REQUEST_IS_ENDED] boolValue];
            if (self.currentRequest&& !requestEnded && [[Utility getInstance] isRequestValid:self.currentRequest.createdAt andTimeAllocated:[[self.currentRequest objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue]]) {
                if (![self isUserStillReceiverForTheRequest]) {
                    [self clearMessagesAndStopUpdate];
                    [self showAlertViewWithMessage:@"You became out the request radius"];
                }
            }
            else {
                // delete all messages
                [self clearMessagesAndStopUpdate];
                [self showAlertViewWithMessage:@"Request time over"];
            }

        });
    });
   }

#pragma mark - Alert view Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];

}
#pragma mark - Is user still in the request
- (BOOL) isUserStillReceiverForTheRequest
{
    return [[ParseManager getInstance] isValidRequestReceiver:self.currentRequest];

//    return  YES;
}

#pragma mark - Show Alert
- (void) showAlertViewWithMessage:(NSString *) message
{
    if (!requestTimeOverAlert) {
        requestTimeOverAlert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [requestTimeOverAlert show];
    }
   }
#pragma mark - Clear Messages
- (void) clearMessagesAndStopUpdate
{
    @try {
        [self.messages removeAllObjects];
        [self.collectionView reloadData];
        [self.timer invalidate];
    }
    @catch (NSException *exception) {
    }
}

#pragma mark - back Button Action
-(void)backButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
