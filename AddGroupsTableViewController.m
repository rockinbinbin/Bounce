//
//  AddGroupsTableViewController.m
//  Hobble
//
//  Created by Robin Mehta on 1/17/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "AddGroupsTableViewController.h"

@interface AddGroupsTableViewController ()

@end

@implementation AddGroupsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        self.navigationItem.hidesBackButton = YES;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SentHobbleRequest"]) {
        self.Request = [PFObject objectWithClassName:@"Requests"];
        self.Request[@"Sender"] = [PFUser currentUser].username;
        self.Request[@"RequestedGroups"] = self.SelectedGroups;
        self.Request[@"Radius"] = [NSNumber numberWithInt:self.radius];
        self.Request[@"TimeAllocated"] = [NSNumber numberWithInt:self.timeAllocated];
        self.Request[@"Location"] = [PFGeoPoint geoPointWithLocation:self.location_manager.location];
        
        [self.Request saveInBackground];
    }
}

- (IBAction)unwind:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
