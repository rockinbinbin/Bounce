//
//  SearchGroupsViewController.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/21/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import "SearchGroupsViewController.h"

// ALL THIS DOES IS SEARCH FOR AND ADD A GROUP

@interface SearchGroupsViewController ()

- (IBAction)CancelButtonPressed:(id)sender;

@end

@implementation SearchGroupsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [PFUser currentUser];
    
    self.finalResults = [[NSArray alloc] init]; //array with names of searched groups only
    self.groups = [[NSArray alloc] init]; //array with all group objects stored in backend
    self.MyGroups = [[NSMutableArray alloc] init]; // array with all of the current users' group objects
    
    self.Names = [[NSMutableArray alloc] init]; // array with all group names
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // find groups current user is a part of
    self.MyGroups = [[PFUser currentUser] objectForKey:@"ArrayOfGroups"]; // filled with group names that i'm a part of
    
    // find ALL group Names
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKeyExists:@"groupName"];
    self.groups = [query findObjects];

    for (PFObject *str in self.groups) {
        NSString *hi = [str objectForKey:@"groupName"];
        [self.Names addObject:hi];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.finalResults count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSString *name = [self.finalResults objectAtIndex:indexPath.row];
        cell.textLabel.text = name;
    }
    
    return cell;
}



// should add groups (add to my groups array + add user to group members) for selected cells
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *usernameSelected = [self.finalResults objectAtIndex:indexPath.row];
    
    PFObject *thisGroup;
    PFObject *Group = [PFObject objectWithClassName:@"Group"];
    
    // find the group in all the groups array that the string selected matches the groName of a group and make a group out of that object
    for (Group in self.groups) {
        if (usernameSelected == [Group objectForKey:@"groupName"]) {
            thisGroup = Group;
        }
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    
    // if user is already a part of the group (if user's objectID is in the ArrayOfUsers key)
    if ([self isInGroup:thisGroup]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        // put up alert - already a friend!
        NSLog(@"Already in group - can't add this user");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hey!"
                                                            message:@"You've already added this group!"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];

    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        // find name of thisGroup
        NSString *name = [thisGroup objectForKey:@"groupName"];
        
        // add group name to ArrayOfGroups for current user
        [[PFUser currentUser] addObject:name forKey:@"ArrayOfGroups"];
        
        // add user to ArrayOfUsers
        [thisGroup addObject:[PFUser currentUser] forKey:@"ArrayOfUsers"];
        
        [self.MyGroups addObject:thisGroup];
        
        NSLog(@"Group added!");
        
    }
    
    // save current user
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    // then save current group
    [thisGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

// should take in a new group to see if its name matches the name in mygroups array
- (BOOL)isInGroup:(PFObject *)group {
    
    PFObject *testgroup = [PFObject objectWithClassName:@"Group"];
    for(testgroup in self.MyGroups) {
        if ([[group objectForKey:@"groupName"] isEqualToString:testgroup]) {
            return YES;
        }
    }
    return NO;
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{

    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", searchText];
    
    self.finalResults = [self.Names filteredArrayUsingPredicate:resultPredicate];

}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{

    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    return YES;
}




- (IBAction)doneButton:(id)sender {
    //[self performSegueWithIdentifier:@"SearchToGroups" sender:self];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)CancelButtonPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
