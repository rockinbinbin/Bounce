//
//  chatCell.m
//  bounce
//
//  Created by Robin Mehta on 7/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "chatCell.h"
#import "UIView+AutoLayout.h"

@implementation chatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UILabel *timeCreated = [UILabel new];
        timeCreated.textColor = BounceRed;
        timeCreated.font = [timeCreated.font fontWithSize:11];
        [self.contentView addSubview:timeCreated];
        self.timeCreated = timeCreated;
        [timeCreated kgn_pinToLeftEdgeOfSuperviewWithOffset:15];
        [timeCreated kgn_pinToTopEdgeOfSuperviewWithOffset:15];
        
        UILabel *timeLeft = [UILabel new];
        timeLeft.textColor = BounceRed;
        timeLeft.font = [timeLeft.font fontWithSize:11];
        [self.contentView addSubview:timeLeft];
        self.requestTimeLeft = timeLeft;
        [timeLeft kgn_pinToRightEdgeOfSuperviewWithOffset:15];
        [timeLeft kgn_pinToTopEdgeOfSuperviewWithOffset:15];
        
        UILabel *lastMessage = [UILabel new];
        lastMessage.textColor = BounceBlue;
        lastMessage.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lastMessage];
        self.lastMessage = lastMessage;
        [lastMessage kgn_centerInSuperview];
        [lastMessage kgn_sizeToWidth:self.frame.size.width - 30];
        
        UILabel *requestedGroups = [UILabel new];
        requestedGroups.textColor = BounceRed;
        requestedGroups.font = [requestedGroups.font fontWithSize:11];
        requestedGroups.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:requestedGroups];
        self.requestedGroups = requestedGroups;
        [requestedGroups kgn_pinToBottomEdgeOfSuperviewWithOffset:15];
        [requestedGroups kgn_pinToLeftEdgeOfSuperviewWithOffset:15];
        [requestedGroups kgn_sizeToWidth:self.frame.size.width - 30];
        
        UIImageView *chatArrow = [UIImageView new];
        chatArrow.image = [UIImage imageNamed:@"chatArrow"];
        [self.contentView addSubview:chatArrow];
        [chatArrow kgn_pinToRightEdgeOfSuperviewWithOffset:15];
        [chatArrow kgn_centerVerticallyInSuperview];
      
    }
    return self;
}


@end
