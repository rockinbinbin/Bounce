//
//  ChatViewController.h
//  bounce
//
//  Created by Shimaa Essam on 3/29/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatView.h"
#import <Parse/Parse.h>

@interface CustomChatViewController : ChatView <UIAlertViewDelegate>
@property PFObject *currentRequest;
@property (strong, nonatomic) id delegate;
@end
