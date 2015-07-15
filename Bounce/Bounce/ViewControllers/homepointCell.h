//
//  homepointCell.h
//  bounce
//
//  Created by Robin Mehta on 7/13/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface homepointCell : UITableViewCell

@property (nonatomic, weak) UIImageView *cellBackground;
@property (nonatomic, weak) UIImage *cellImage;
@property (nonatomic, weak) UILabel *homepointName;
@property (nonatomic, weak) UILabel *friendsinHomepoint;
@property (nonatomic, weak) UILabel *distanceAway;

@end
