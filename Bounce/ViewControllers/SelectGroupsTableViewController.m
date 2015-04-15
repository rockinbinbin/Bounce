//
//  SelectGroupsTableViewController.m
//  bounce
//
//  Created by Shimaa Essam on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "SelectGroupsTableViewController.h"
#import "ParseManager.h"
#import "HomeScreenViewController.h"
#import "AppConstant.h"
#import "RequestManger.h"
#import "Utility.h"

@interface SelectGroupsTableViewController ()

@end

@implementation SelectGroupsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.navigationController setNavigationBarHidden:NO];
    UIBarButtonItem *DoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)];
   
    self.navigationItem.rightBarButtonItem = DoneButton;

    
    self.SelectedGroups = [NSMutableArray array];
    
    self.location_manager = [[CLLocationManager alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.groups = [[PFUser currentUser] objectForKey:@"ArrayOfGroups"];
    // load all groups instead using the user groups
    [self loadAllGroups];
    
    NSLog(@"radius = %d", self.radius);
    NSLog(@"time allocated = %d", self.timeAllocated);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *group = [self.groups objectAtIndex:indexPath.row];
    cell.textLabel.text = group;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([selectedCell accessoryType] == UITableViewCellAccessoryNone) {
        [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.SelectedGroups addObject:[self.groups objectAtIndex:indexPath.row]];
        
    }
    else {
        [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
        [self.SelectedGroups removeObject:[self.groups objectAtIndex:indexPath.row]];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
}

- (void)didSelectMultipleUsers:(NSArray *)users {
    //    [self.delegate didSelectMultipleUsers:users];
}

- (IBAction)unwind:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonPressed{
    
    if ([self.SelectedGroups count]) {
//        [[RequestManger getInstance] createrequestToGroups:self.SelectedGroups andGender:self.genderFilter withinTime:self.timeAllocated andInRadius:self.radius];
        
        // MOVE TO HOME
        HomeScreenViewController *homeViewController = [[HomeScreenViewController alloc] init];
        [self.navigationController pushViewController:homeViewController animated:YES];
    }
    else {
        UIAlertView *zerolength = [[UIAlertView alloc] initWithTitle:@"yo!"
                                                             message:@"Please check at least one group!"
                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [zerolength show];
    }
    
}

#pragma mark - load all groups
- (void) loadAllGroups{
    
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Loading..." withView:self.view];
            [[ParseManager getInstance] setGetUserGroupsdelegate:self];
            [[ParseManager getInstance] getUserGroups];
    }

//        [[Utility getInstance] showProgressHudWithMessage:@"loading..." withView:self.view];
//        NSArray *objects = [[ParseManager getInstance] getUserGroups];
//        [[Utility getInstance]hideProgressHud];
//        if ([objects count] > 0) {
//            // get name of each group
//            self.groups = [[NSMutableArray alloc]init];
//            for (PFObject *group in objects) {
//                [self.groups addObject:[group objectForKey:@"groupName"] ];
//            }
//            [self.tableView reloadData];
//        }
//    }
    

    
//    PFQuery *query = [PFQuery queryWithClassName:PF_GROUPS_CLASS_NAME];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//     {
//         
//         if ([objects count] > 0) {
//             // get name of each group
//             self.groups = [[NSMutableArray alloc]init];
//             for (PFObject *group in objects) {
//                 [self.groups addObject:[group objectForKey:@"groupName"] ];
//             }
//             [self.tableView reloadData];
//         }
//         
//     }];
}

#pragma mark - Get user groups delegate
- (void)didLoadUserGroups:(NSArray *)groups WithError:(NSError *)error
{
    @try {
        if (!error) {
            [[Utility getInstance]hideProgressHud];
            if ([groups count] > 0) {
                // get name of each group
                self.groups = [[NSMutableArray alloc]init];
                for (PFObject *group in groups) {
                    [self.groups addObject:[group objectForKey:PF_GROUPS_NAME] ];
                }
                [self.tableView reloadData];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

@end
