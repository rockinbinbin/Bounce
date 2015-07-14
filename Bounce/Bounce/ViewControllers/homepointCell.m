//
//  homepointCell.m
//  bounce
//
//  Created by Robin Mehta on 7/13/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "homepointCell.h"
#import "UIView+AutoLayout.h"

@implementation homepointCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.cellBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        UIView *overlay = [UIView new];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [self.cellBackground addSubview:overlay];
        [overlay kgn_sizeToWidthAndHeightOfItem:self.cellBackground];
        self.backgroundView = self.cellBackground;
        
        self.homepointName = [UILabel new];
        self.homepointName.translatesAutoresizingMaskIntoConstraints = NO;
        self.homepointName.textColor = [UIColor whiteColor];
        self.homepointName.font = [UIFont fontWithName:@"Quicksand-Regular" size:self.frame.size.height]; // fix this value
        [self.contentView addSubview:self.homepointName];
        [self.homepointName kgn_centerHorizontallyInSuperview];
        [self.homepointName kgn_centerVerticallyInSuperviewWithOffset:-40];
        
        self.friendsinHomepoint = [UILabel new];
        self.friendsinHomepoint.translatesAutoresizingMaskIntoConstraints = NO;
        self.friendsinHomepoint.textColor = [UIColor whiteColor];
        self.friendsinHomepoint.font = [UIFont fontWithName:@"Quicksand-Regular" size:self.frame.size.height/3.5];
        [self.contentView addSubview:self.friendsinHomepoint];
        [self.friendsinHomepoint kgn_pinToBottomEdgeOfSuperviewWithOffset:10];
        [self.friendsinHomepoint kgn_pinToLeftEdgeOfSuperviewWithOffset:10];
        
        self.distanceAway = [UILabel new];
        self.distanceAway.translatesAutoresizingMaskIntoConstraints = NO;
        self.distanceAway.textColor = [UIColor whiteColor];
        self.distanceAway.font = [UIFont fontWithName:@"Quicksand-Regular" size:self.frame.size.height/2.75];
        [self.contentView addSubview:self.distanceAway];
        [self.distanceAway kgn_centerHorizontallyInSuperview];
        [self.distanceAway kgn_centerVerticallyInSuperviewWithOffset:15];

    }
    return self;
}

@end
