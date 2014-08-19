//
//  SearchFriendsViewController.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/18/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import "SearchFriendsViewController.h"

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
    
    self.currentUser = [PFUser currentUser];
    self.friendsRelation = self.friendclass.friendsRelation; // what does this mean??
    // self.friendclass.friends = ??? ;
    self.searchResults = [[NSArray alloc] init];
    self.finalResults = [[NSArray alloc] init];
    self.usernames = [[NSMutableArray alloc] init];
    
    NSLog(@"User Info %@", self.currentUser.username); // works. username: @roro
    
    
    PFQuery *query = [PFUser query];
    self.searchResults = [query findObjects];
    
    // after query: test - print all usernames in parse
    PFUser *user;
    for (user in self.searchResults) {
        //NSLog(@"User Info: %@", user.username);
        [self.usernames addObject:user.username];
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 71;
//}

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
//    user = [self.finalResults objectAtIndex:indexPath.row];
        NSString *name = [self.finalResults objectAtIndex:indexPath.row];
        cell.textLabel.text = name;
    }
    return cell;
}





// should add friends (+ add relation) for selected cells - not tested
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSString *usernameSelected = [self.finalResults objectAtIndex:indexPath.row];
    PFUser *thisUser;
    
    for (PFUser *user in self.searchResults) {
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
                [self.friendclass.friends addObject:thisUser];
                [_friendsRelation addObject:thisUser];
        NSLog(@"User added as friend!");
  
    }
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
    for (PFUser *user in self.friendclass.friends) {
        NSLog(user.username);
    }
    
}



// uh
- (BOOL)isFriend:(PFUser *)user {
    for(PFUser *friend in _friendclass.friends) {
        if ([friend.objectId isEqualToString:user.objectId]) {
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
