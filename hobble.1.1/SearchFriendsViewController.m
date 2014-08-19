//
//  SearchFriendsViewController.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/18/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import "SearchFriendsViewController.h"

@interface SearchFriendsViewController ()

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
    self.friendsRelation = self.friendclass.friendsRelation;
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

@end
