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
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *chatArrow = [UIImageView new];
        chatArrow.image = [UIImage imageNamed:@"chatArrow"];
        [self.contentView addSubview:chatArrow];
        [chatArrow kgn_pinToRightEdgeOfSuperviewWithOffset:15];
        [chatArrow kgn_centerVerticallyInSuperview];
        
        UIImageView *hpImage = [UIImageView new];
        [self.contentView addSubview:hpImage];
        self.hpImage = hpImage;
        [hpImage kgn_sizeToHeight:70];
        [hpImage kgn_sizeToWidth:70];
        [hpImage kgn_pinToLeftEdgeOfSuperviewWithOffset:30];
        [hpImage kgn_centerVerticallyInSuperview];
        
        UILabel *requestedGroups = [UILabel new];
        requestedGroups.textColor = BounceRed;
        requestedGroups.font = [UIFont fontWithName:@"Avenir-Light" size:20];
        requestedGroups.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:requestedGroups];
        self.requestedGroups = requestedGroups;
        [requestedGroups kgn_pinTopEdgeToTopEdgeOfItem:self.hpImage];
        [requestedGroups kgn_centerHorizontallyInSuperview];
        
        UILabel *timeLeft = [UILabel new];
        timeLeft.textColor = BounceRed;
        timeLeft.font = [UIFont fontWithName:@"Avenir-Light" size:15];
        [self.contentView addSubview:timeLeft];
        self.requestTimeLeft = timeLeft;
        [timeLeft kgn_pinLeftEdgeToLeftEdgeOfItem:requestedGroups];
        [timeLeft kgn_pinBottomEdgeToBottomEdgeOfItem:requestedGroups withOffset:30];
      
    }
    return self;
}


@end
