//
//  SearchFriendsViewController.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/18/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import "SearchFriendsViewController.h"

// ALL THIS DOES IS SEARCH FOR AND ADD A FRIEND RELATION

@interface SearchFriendsViewController ()

- (IBAction)AddButton:(id)sender;

@end

@implementation SearchFriendsViewController

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
    
    //self.navigationItem.hidesBackButton = NO;
    self.currentUser = [PFUser currentUser];
    self.searchResults = [[NSArray alloc] init];
    self.finalResults = [[NSArray alloc] init];
//    self.friendUsers = [[NSMutableArray alloc] init];
    self.usernames = [[NSMutableArray alloc] init];
    self.friendsRelation = [[PFUser currentUser] objectForKey:ParseFriendRelation];
    
    NSLog(@"User Info %@", self.currentUser.username); // works. username: @roro
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // find all users
    PFQuery *query = [PFUser query];
    self.searchResults = [query findObjects];
    // after query: test - print all usernames in parse
    PFUser *user;
    for (user in self.searchResults) {
        [self.usernames addObject:user.username];
    }
    
    // find all friends
    PFQuery *querytwo = [self.friendsRelation query];
    [querytwo orderByAscending:ParseUsername];
    [querytwo findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        else {
            self.friendUsers =(NSMutableArray *)objects; // warning OK
        }
    }];
    
    for (PFUser *friend in self.friendUsers) {
        NSLog(@"friendUsers:%@", friend.username);
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
    
//    PFUser *user;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSString *name = [self.finalResults objectAtIndex:indexPath.row];
        cell.textLabel.text = name;
    }
    return cell;
}


// should add friends (+ add relation) for selected cells
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSString *usernameSelected = [self.finalResults objectAtIndex:indexPath.row];
    PFUser *thisUser;
    
    for (PFUser *user in self.searchResults) { // find the user in all users group that has the username of the username selected, and make a user out of it
        if (usernameSelected == user.username) {
            thisUser = user;
        }
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if ([self isFriend:thisUser]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        // put up alert - already a friend!
        NSLog(@"Already a friend - can't add this user");
        
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [self.friendUsers addObject:thisUser];
                [_friendsRelation addObject:thisUser];
        NSLog(@"User added as friend!");
    }
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
//    for (PFUser *user in self.friendUsers) {
//        NSLog(user.username);
//    }
    
}

- (BOOL)isFriend:(PFUser *)user { // take in a new user to see if matches an ID in my friends array
    for(PFUser *friend in self.friendUsers) {
        if ([friend.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    
    return NO;
}


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", searchText];
 
    
    self.finalResults = [self.usernames filteredArrayUsingPredicate:resultPredicate];
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

- (IBAction)AddButton:(id)sender {
    [self performSegueWithIdentifier:@"SearchToFriends" sender:self];
}
@end
