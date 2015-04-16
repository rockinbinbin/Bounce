//
//  MessagesTableCell.m
//  bounce
//
//  Created by Robin Mehta on 3/9/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "AppConstant.h"
#import "utilities.h"

#import "MessagesTableCell.h"

@interface MessagesTableCell() {
    PFObject *message;
}

@property (strong, nonatomic) IBOutlet PFImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelLastMessage;
@property (strong, nonatomic) IBOutlet UILabel *labelElapsed;
@property (strong, nonatomic) IBOutlet UILabel *labelCounter;


@end

@implementation MessagesTableCell

- (void)bindData:(PFObject *)message_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    message = message_;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    _imageUser.layer.cornerRadius = _imageUser.frame.size.width/2;
    _imageUser.layer.masksToBounds = YES;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFUser *lastUser = message[PF_MESSAGES_LASTUSER];
    [_imageUser setFile:lastUser[PF_USER_PICTURE]];
    [_imageUser loadInBackground];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    _labelDescription.text = message[PF_MESSAGES_DESCRIPTION];
    _labelLastMessage.text = message[PF_MESSAGES_LASTMESSAGE];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:message[PF_MESSAGES_UPDATEDACTION]];
    _labelElapsed.text = TimeElapsed(seconds);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    int counter = [message[PF_MESSAGES_COUNTER] intValue];
    _labelCounter.text = (counter == 0) ? @"" : [NSString stringWithFormat:@"%d new", counter];
}


@end
