//
//  AddGroupsTableViewController.m
//  Hobble
//
//  Created by Robin Mehta on 1/17/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "AddGroupsTableViewController.h"

@interface AddGroupsTableViewController ()
- (IBAction)doneButtonPressed:(id)sender;

@end

@implementation AddGroupsTableViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.SelectedGroups = [NSMutableArray array];
    
    self.location_manager = [[CLLocationManager alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.groups = [[PFUser currentUser] objectForKey:@"ArrayOfGroups"];
    
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
    [self.delegate didSelectMultipleUsers:users];
}

- (IBAction)unwind:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneButtonPressed:(id)sender {
    /*
        Code to submit request goes here
     
     */
    
    if ([self.SelectedGroups count]) {
        
        PFQuery *query = [PFUser query];
        PFUser *currentUser = [PFUser currentUser];
        PFGeoPoint *userGeoPoint = currentUser[@"CurrentLocation"];
        
        NSMutableArray *queries = [[NSMutableArray alloc] init];
        
        // go through all groups to find users who are near
        for (NSString *groupName in self.SelectedGroups) {
            PFQuery *query = [PFUser query];
            [query whereKey:@"username" notEqualTo:currentUser.username];
            [query whereKey:@"ArrayOfGroups" equalTo:groupName];
            [query whereKey:@"CurrentLocation" nearGeoPoint:userGeoPoint withinMiles:self.radius];
            [queries addObject:query];
        }
        
        query = [PFQuery orQueryWithSubqueries:queries];
        NSArray *resultUsers = [query findObjects];
        
        NSMutableArray *resultUsernames = [[NSMutableArray alloc] init];
        
        for (PFUser *user in resultUsers) {
            NSLog(@"%@", user.username);
            [resultUsernames addObject:user.username];
        }
        
        if ([resultUsers count] != 0) {
            // NSLog(@"%@", resultUsers[0][@"DeviceID"]);
            
            self.Request = [PFObject objectWithClassName:@"Requests"];
            self.Request[@"Sender"] = [PFUser currentUser].username;
            self.Request[@"receivers"] = resultUsernames;
            
            
            self.Request[@"RequestedGroups"] = self.SelectedGroups;
            self.Request[@"Radius"] = [NSNumber numberWithInt:self.radius];
            self.Request[@"TimeAllocated"] = [NSNumber numberWithInt:self.timeAllocated];
            self.Request[@"Location"] = [PFGeoPoint geoPointWithLocation:self.location_manager.location];
            [self.Request saveInBackground];
            
            // SET DELEGATE HERE
            if (delegate != nil) {
                NSLog(@"DELEGATE IS NOT NIL");
                [self didSelectMultipleUsers:resultUsernames];
            }
            
        } else {
            NSLog(@"There were no users found.");
        }
        
        //            PFPush *push = [[PFPush alloc] init];
        
        //            PFQuery *newQuery = [PFInstallation query];
        //            [newQuery whereKey:@"deviceToken" equalTo:@"1f7d051e4b7a1c8f5e476143cfa3b967c98eebf56c98497308c0c87128c9696b"];
        //
        //            [push setQuery:newQuery];
        //            [push setMessage:@"Steven needs your help! Call him at 248-924-5123."];
        //            [push sendPushInBackground];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        UIAlertView *zerolength = [[UIAlertView alloc] initWithTitle:@"yo!"
                                                             message:@"Please check at least one group!"
                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [zerolength show];
    }

}
@end
