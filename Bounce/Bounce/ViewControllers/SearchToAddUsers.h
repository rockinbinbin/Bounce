//
//  SearchToAddUsers.h
//  bounce
//
//  Created by Robin Mehta on 8/15/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"

@interface SearchToAddUsers : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *candidateUsers;

@end