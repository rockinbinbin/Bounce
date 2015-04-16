//
//  MessagesTableCell.h
//  bounce
//
//  Created by Robin Mehta on 3/9/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MessagesTableCell : UITableViewCell

- (void)bindData:(PFObject *)message_;

@end
