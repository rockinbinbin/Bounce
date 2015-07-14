//
//  homepointCell.h
//  bounce
//
//  Created by Robin Mehta on 7/13/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface homepointCell : UITableViewCell

@property (nonatomic, strong) UIImageView *cellBackground;
@property (nonatomic, strong) UIImage *cellImage;
@property (nonatomic, strong) UILabel *homepointName;
@property (nonatomic, strong) UILabel *friendsinHomepoint;
@property (nonatomic, strong) UILabel *distanceAway;

@end
