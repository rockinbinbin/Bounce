//
//  addUsersCell.m
//  bounce
//
//  Created by Robin Mehta on 8/13/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "membersCell.h"
#import "UIView+AutoLayout.h"

@implementation membersCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
        self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
        if (self) {
        
                UILabel *addedBy = [UILabel new];
                addedBy.translatesAutoresizingMaskIntoConstraints = NO;
                addedBy.textColor = [UIColor blackColor];
                addedBy.font = [UIFont fontWithName:@"Avenir-Light" size:28];
                [self.contentView addSubview:addedBy];
                [addedBy kgn_centerHorizontallyInSuperview];
                [addedBy kgn_centerVerticallyInSuperviewWithOffset:-40];
                self.addedBy = addedBy;
        
                UIImageView *profileImage = [UIImageView new];
                [self.contentView addSubview:profileImage];
                self.profileImage = profileImage;
                [profileImage kgn_sizeToHeight:80];
                [profileImage kgn_sizeToWidth:80];
                [profileImage kgn_pinToLeftEdgeOfSuperviewWithOffset:20];
                [profileImage kgn_centerVerticallyInSuperview];
            
            self.profileImage.layer.borderWidth = 6.0f;
            self.profileImage.layer.borderColor = [BounceSeaGreen CGColor];
            self.profileImage.layer.cornerRadius = 40.0f;
            self.profileImage.clipsToBounds = true;
            
            UILabel *name = [UILabel new];
            name.translatesAutoresizingMaskIntoConstraints = NO;
            name.textColor = [UIColor blackColor];
            name.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22];
            [self.contentView addSubview:name];
            [name kgn_centerVerticallyInSuperview];
            [name kgn_positionToTheRightOfItem:profileImage withOffset:20];
            self.name = name;
        
                UIButton *iconView = [UIButton new];
                [self.contentView addSubview:iconView];
                self.iconView = iconView;
                [iconView kgn_pinToRightEdgeOfSuperviewWithOffset:20];
                [iconView kgn_centerVerticallyInSuperview];
            
                UILabel *requestSent = [UILabel new];
                requestSent.translatesAutoresizingMaskIntoConstraints = NO;
                requestSent.textColor = [UIColor blackColor];
                requestSent.font = [UIFont fontWithName:@"Avenir-Light" size:12];
                requestSent.text = nil;
                [self.contentView addSubview:requestSent];
                [requestSent kgn_centerVerticallyInSuperview];
                [requestSent kgn_pinToRightEdgeOfSuperviewWithOffset:20];
                self.requestAdded = requestSent;
            }
        return self;
    }


@end