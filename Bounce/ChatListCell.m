//
//  ChatListCell.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "ChatListCell.h"

#import "AppConstant.h"
@interface ChatListCell ()

@end

@implementation ChatListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    if (self) {
        // make the circularView rounder
        self.circularView.layer.cornerRadius = self.circularView.frame.size.height / 2;
        self.circularView.clipsToBounds = YES;
        self.circularView.layer.borderWidth = 3.0f;
        self.circularView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.circularView.backgroundColor = BounceRed;
        
        // rounded view on the left
        CGRect userOnlineFrame = CGRectMake(self.circularView.frame.origin.x + 48, self.circularView.frame.origin.y + 8, 20, 20);
        self.roundedView = [[UIView alloc] initWithFrame: userOnlineFrame];
        self.roundedView.layer.cornerRadius = 10;
        self.roundedView.layer.masksToBounds = YES;
        self.roundedView.backgroundColor = [UIColor redColor];
        
        // number of messages for the group
        self.numOfMessagesLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5, 0, 30, 20)];
        self.numOfMessagesLabel.textAlignment = NSTextAlignmentCenter;
        [self.numOfMessagesLabel setTextColor:[UIColor whiteColor]];
        [self.numOfMessagesLabel setBackgroundColor:[UIColor clearColor]];
        [self.numOfMessagesLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
        [self.roundedView addSubview:self.numOfMessagesLabel];
        [self addSubview:self.roundedView];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
