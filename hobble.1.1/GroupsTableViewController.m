//
//  GroupsTableViewController.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/11/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import "GroupsTableViewController.h"

// ALL THIS DOES IS LIST GROUPS NAMES IN TABLE VIEW

@interface GroupsTableViewController ()
- (IBAction)createGroupsButtonPressed:(id)sender;
- (IBAction)searchGroupsButtonPressed:(id)sender;

@end

@implementation GroupsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.groups = [[PFUser currentUser] objectForKey:@"ArrayOfGroups"];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.

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

- (IBAction)createGroupsButtonPressed:(id)sender {
}

- (IBAction)searchGroupsButtonPressed:(id)sender {
}
@end
