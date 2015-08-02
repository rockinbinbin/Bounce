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
        timeCreated.font = [UIFont fontWithName:@"Avenir-Next" size:self.frame.size.height/3];
        [self.contentView addSubview:timeCreated];
        self.timeCreated = timeCreated;
        [timeCreated kgn_pinToLeftEdgeOfSuperviewWithOffset:15];
        [timeCreated kgn_pinToBottomEdgeOfSuperviewWithOffset:15];
        
        UILabel *timeLeft = [UILabel new];
        timeLeft.textColor = BounceRed;
        timeLeft.font = [UIFont fontWithName:@"Avenir-Next" size:self.frame.size.height/3];
        [self.contentView addSubview:timeLeft];
        self.requestTimeLeft = timeLeft;
        [timeLeft kgn_centerHorizontallyInSuperview];
        [timeLeft kgn_pinToTopEdgeOfSuperviewWithOffset:15];
        
        UILabel *lastMessage = [UILabel new];
        lastMessage.textColor = [UIColor grayColor];
        lastMessage.font = [UIFont fontWithName:@"Avenir-Next" size:self.frame.size.height/3];
        lastMessage.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:lastMessage];
        self.lastMessage = lastMessage;
        [lastMessage kgn_centerHorizontallyInSuperviewWithOffset:-self.frame.size.width / 3];
        [lastMessage kgn_centerVerticallyInSuperview];
        
      
    }
    return self;
}


@end
