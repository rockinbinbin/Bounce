//
//  GroupsListViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "GroupsListViewController.h"
#import "EditGroupsViewController.h"
#import "ChatListCell.h"
#import "AppConstant.h"
#import "Utility.h"
#import "Constants.h"

@interface GroupsListViewController ()
@end

@implementation GroupsListViewController
@synthesize nearUsers = nearUsers;
@synthesize distanceToUserLocation = distanceToUserLocation;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];

    [self setBarButtonItemLeft:@"common_back_button"];
    self.navigationItem.title = @"homepoints";
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Edit"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(editButtonClicked)];
    editButton.tintColor = DEFAULT_COLOR;
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    @try {
        //        [[ParseManager getInstance] setLoadGroupsdelegate:self];
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Loading..." withView:self.view];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //                [[ParseManager getInstance] loadAllGroups];
                self.groups = [[NSMutableArray alloc] initWithArray:[[ParseManager getInstance] getUserGroups]];
                nearUsers = [[NSMutableArray alloc] init];
                distanceToUserLocation = [[NSMutableArray alloc] init];
                for (PFObject *group in self.groups) {
                    [nearUsers addObject:[NSNumber numberWithInteger:[[ParseManager getInstance] getNearUsersInGroup:group]]];
                    [distanceToUserLocation addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    [[Utility getInstance] hideProgressHud];
                    [self.tableView reloadData];
                });
            });
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName{

    UIImage *back = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:back withAction:@selector(backButtonClicked)];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}

-(void)backButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)editButtonClicked{
    EditGroupsViewController* editGroupViewController = [[EditGroupsViewController alloc] initWithNibName:@"EditGroupsViewController" bundle:nil];
    [editGroupViewController setGroups:self.groups];
    [editGroupViewController setNearUsers:self.nearUsers];
    [editGroupViewController setDistanceToUserLocation:self.distanceToUserLocation];

    [self.navigationController pushViewController:editGroupViewController animated:YES];
}
#pragma mark - Parse LoadGroups delegate
- (void)didLoadGroups:(NSArray *)groups withError:(NSError *)error
{
    @try {
        [[Utility getInstance] hideProgressHud];
        if (!error) {
            if(!self.groups)
            {
                self.groups = [[NSMutableArray alloc] init];
            }
            
            self.groups = [NSMutableArray arrayWithArray:groups];
            // calculate the near users in each group
            // calcultae the distance to the group
            nearUsers = [[NSMutableArray alloc] init];
            distanceToUserLocation = [[NSMutableArray alloc] init];
            
            for (PFObject *group in groups) {
                [nearUsers addObject:[NSNumber numberWithInteger:[[ParseManager getInstance] getNearUsersInGroup:group]]];
                [distanceToUserLocation addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
            }
            
            [self.tableView reloadData];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"ChatListCell";
    ChatListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
        cell = (ChatListCell *)[nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
  
    cell.numOfMessagesLabel.text = @"0";
    // filling the cell data
//    cell.groupNameLabel.text = @"Group 1";
//    cell.groupDistanceLabel.text = @"2.1 miles away";
//    cell.numOfFriendsInGroupLabel.text = @"44";
    
    cell.groupNameLabel.text = [[self.groups objectAtIndex:indexPath.row] objectForKey:PF_GROUPS_NAME];
    cell.groupDistanceLabel.text = [NSString stringWithFormat:DISTANCE_MESSAGE, [[distanceToUserLocation objectAtIndex:indexPath.row] doubleValue]];
    cell.numOfFriendsInGroupLabel.text = [NSString stringWithFormat:@"%@",[nearUsers objectAtIndex:indexPath.row]];
    NSLog(@"near users %@", [nearUsers objectAtIndex:indexPath.row]);
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}


@end
