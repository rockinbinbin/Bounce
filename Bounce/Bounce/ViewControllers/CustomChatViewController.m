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
#import "UIView+AutoLayout.h"

@interface CustomChatViewController ()

@end

@implementation CustomChatViewController
{
    UIAlertView *requestTimeOverAlert;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.homepointChat = NO;
    
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"Quicksand-Regular" size:self.view.frame.size.height/23];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"Leaving soon";
    [navLabel sizeToFit];
    
    self.navigationController.navigationBar.barTintColor = BounceRed;
    self.navigationController.navigationBar.translucent = NO;
    UIButton *customButton = [[Utility getInstance] createCustomButton:[UIImage imageNamed:@"common_back_button"]];
    [customButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
                    [self showAlertViewWithMessage:@"Oops! Looks like you're no longer within the request radius."];
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
