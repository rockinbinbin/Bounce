//
//  SearchGroupsViewController.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/21/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import "SearchGroupsViewController.h"

// ALL THIS DOES IS SEARCH FOR AND ADD A GROUP RELATION

@interface SearchGroupsViewController ()

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
    
    
    
    NSLog(@"got to search view did load");
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // find groups current user is a part of
    self.MyGroups = [[PFUser currentUser] objectForKey:@"ArrayOfGroups"]; // filled with group names that i'm a part of
    
    // find ALL group Names
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKeyExists:@"groupName"];
//    [query includeKey:@"groupName"];
//    [query selectKeys:@[@"groupName"]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (error) {
//            NSLog(@"Error");
//        }
//        else {
//            self.groups = objects;
////            int a = 0;
////            a = [objects count];
////            NSLog(@"A = %d", a);
////            for (PFObject *str in objects) {
//////                NSLog(@"%@", str);
////                NSString *hi = [str objectForKey:@"groupName"];
////                NSLog(@"HI = %@", hi);
////                [self.Names addObject:hi];
////            }
//        }
//    }];
    self.groups = [query findObjects];

    
    
    int a = 0;
    a = [self.groups count];
    NSLog(@"A = %d", a);
    for (PFObject *str in self.groups) {
        //                NSLog(@"%@", str);
        NSString *hi = [str objectForKey:@"groupName"];
        NSLog(@"HI = %@", hi);
        [self.Names addObject:hi];
    }
    
    
    
    
//    // find ALL group objects
//    PFQuery *twoquery = [PFQuery queryWithClassName:@"Group"];
//    [twoquery whereKeyExists:@"groupName"];
//    [twoquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (error) {
//            NSLog(@"Error");
//        }
//        else {
//            int a = 0;
//            a = [objects count];
//            NSLog(@"A = %d", a);
//            for (PFObject *str in objects) {
//                [self.Names addObject:str];
//            }
//        }
//    }];
    
    
    
////    for (NSString *name in self.MyGroups) {
////        NSLog(name);
////    } // name works
//    int count = 0;
//    [self.Names count];
//    NSLog(@"COUNT: %d", count);
    
//    int count = 0;
//    for (NSString *name in self.Names) {
//        NSLog(@"GOT HEREEE");
//        NSLog(@"%d", count);
//        count++;
//        NSLog(@"%@", name);
//    }
//
// //    ERROR
//    for (NSString *string in self.groups) {
//        NSLog(string);
//    }
    

    NSLog(@"got to search view will appear");
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"A");
    return [self.finalResults count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"B");
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSLog(@"UPPP");
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"HIIIII");
        NSString *name = [self.finalResults objectAtIndex:indexPath.row];
        cell.textLabel.text = name;
    }
    
    NSLog(@"got to search cell for row at index path");
    return cell;
}



// should add groups (add to my groups array + add user to group members) for selected cells
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"C");
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
        
        NSLog(@"User added as friend!");
        
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
    
    NSLog(@"D");
    
    PFObject *testgroup = [PFObject objectWithClassName:@"Group"];
    for(testgroup in self.MyGroups) {
        if ([[group objectForKey:@"groupName"] isEqualToString:testgroup]) {
            return YES;
        }
    }
    
    return NO;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSLog(@"E");
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", searchText];
    
    
    self.finalResults = [self.Names filteredArrayUsingPredicate:resultPredicate];
    NSLog(@"End of E");
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"F");
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    NSLog(@"End of F");
    return YES;
}




- (IBAction)doneButton:(id)sender {
    [self performSegueWithIdentifier:@"SearchToGroups" sender:self];
}
@end
