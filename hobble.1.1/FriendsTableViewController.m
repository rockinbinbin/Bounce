//
//  FriendsTableViewController.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/8/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "APAddressBook.h"

// ALL THIS DOES IS LIST YOUR FRIENDS IN TABLE VIEW


@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController


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
    
    self.navigationItem.hidesBackButton = YES;
    // assign friends relation (that was created in edit friends)
    self.friendsRelation = [[PFUser currentUser] objectForKey:ParseFriendRelation]; // defines relation as amount of friends in current user
    self.currentUser = [PFUser currentUser];
    
    
    // if user is a first time user: ask if they want to populate friends from contacts
    // in new backend, not sure how to store if user is first time user
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Load friends from contacts?"
                                                            message:@"Locale is fun with friends!"
                                                           delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"OK!", nil];
    alertView.delegate = self;
    [alertView show];
    
}

- (BOOL)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"user pressed Cancel");
        NSLog(@"%d", buttonIndex);
        return NO;
    }
    else {
    NSLog(@"user pressed OK");
    NSLog(@"%d", buttonIndex);
        return YES;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:ParseUsername];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        else {
            self.friends = objects; // warning OK
            [self.tableView reloadData];
        }
    }];
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
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;

    
    return cell;
}

@end
