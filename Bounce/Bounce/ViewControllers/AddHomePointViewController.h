//
//  AddHomePointViewController.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseManager.h"

@interface AddHomePointViewController : UIViewController<ParseManagerUpdateGroupDelegate, ParseManagerDelegate, ParseManagerLoadingGroupsDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UICollectionView *collectionView;

@property NSMutableArray *homepointImages;

-(void)navigateToCreateHomepointView;

@end
