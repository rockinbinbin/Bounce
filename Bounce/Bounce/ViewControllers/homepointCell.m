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

        UIImageView *cellBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        UIView *overlay = [UIView new];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [cellBackground addSubview:overlay];
        [overlay kgn_sizeToWidthAndHeightOfItem:cellBackground];
        self.backgroundView = cellBackground;
        self.cellBackground = cellBackground;
        
        UILabel *homepointName = [UILabel new];
        homepointName.translatesAutoresizingMaskIntoConstraints = NO;
        homepointName.textColor = [UIColor whiteColor];
        homepointName.font = [UIFont fontWithName:@"Quicksand-Regular" size:self.frame.size.height]; // fix this value
        [self.contentView addSubview:homepointName];
        [homepointName kgn_centerHorizontallyInSuperview];
        [homepointName kgn_centerVerticallyInSuperviewWithOffset:-40];
        self.homepointName = homepointName;
        
        UILabel *friendsinHomepoint = [UILabel new];
        friendsinHomepoint.translatesAutoresizingMaskIntoConstraints = NO;
        friendsinHomepoint.textColor = [UIColor whiteColor];
        friendsinHomepoint.font = [UIFont fontWithName:@"Quicksand-Regular" size:self.frame.size.height/3.5];
        [self.contentView addSubview:friendsinHomepoint];
        [friendsinHomepoint kgn_pinToBottomEdgeOfSuperviewWithOffset:10];
        [friendsinHomepoint kgn_pinToLeftEdgeOfSuperviewWithOffset:10];
        self.friendsinHomepoint = friendsinHomepoint;
        
        UILabel *distanceAway = [UILabel new];
        distanceAway.translatesAutoresizingMaskIntoConstraints = NO;
        distanceAway.textColor = [UIColor whiteColor];
        distanceAway.font = [UIFont fontWithName:@"Quicksand-Regular" size:self.frame.size.height/2.75];
        [self.contentView addSubview:distanceAway];
        [distanceAway kgn_centerHorizontallyInSuperview];
        [distanceAway kgn_centerVerticallyInSuperviewWithOffset:15];
        self.distanceAway = distanceAway;
    }
    return self;
}

@end
