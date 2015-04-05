//
//  ChatListCell.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfFriendsInGroupLabel;
@property (weak, nonatomic) IBOutlet UILabel *nearbyLabel;
@property (weak, nonatomic) IBOutlet UIView *circularView;


@property BOOL isSelected;
@property (strong, nonatomic) NSString* numOfMessages;
@property (strong, nonatomic) UILabel *numOfMessagesLabel;
@property (strong, nonatomic) UIView* roundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circularViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circularViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceTitleConstraints;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@end
