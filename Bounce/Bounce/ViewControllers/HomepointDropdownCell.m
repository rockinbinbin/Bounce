//
//  HomepointDropdownCell.m
//  bounce
//
//  Created by Robin Mehta on 8/31/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "HomepointDropdownCell.h"
#import "UIView+AutoLayout.h"

@implementation HomepointDropdownCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *hpImage = [UIImageView new];
        [self.contentView addSubview:hpImage];
        self.hpImage = hpImage;
        [hpImage kgn_sizeToHeight:65];
        [hpImage kgn_sizeToWidth:65];
        [hpImage kgn_pinToLeftEdgeOfSuperviewWithOffset:40];
        [hpImage kgn_centerVerticallyInSuperview];
        self.hpImage.layer.borderWidth = 4.0f;
        self.hpImage.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.hpImage.layer.cornerRadius = 32.5f;
        self.hpImage.clipsToBounds = true;
        
        UILabel *requestedGroups = [UILabel new];
        requestedGroups.textColor = [UIColor blackColor];
        requestedGroups.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22];
        requestedGroups.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:requestedGroups];
        self.homepointName = requestedGroups;
        [requestedGroups kgn_pinTopEdgeToTopEdgeOfItem:self.hpImage withOffset:-5];
        [requestedGroups kgn_positionToTheRightOfItem:hpImage withOffset:25];
        
        UILabel *nearbyUsers = [UILabel new];
        nearbyUsers.textColor = [UIColor grayColor];
        nearbyUsers.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16];
        nearbyUsers.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:nearbyUsers];
        [nearbyUsers kgn_positionToTheRightOfItem:requestedGroups withOffset:10];
    }
    return self;
}

@end
