//
//  SearchToAddGroups.h
//  bounce
//
//  Created by Robin Mehta on 8/16/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"

@interface SearchToAddGroups : UITableViewController <UISearchResultsUpdating, UISearchControllerDelegate>

@property (nonatomic, strong) NSArray *allGroups;

@end