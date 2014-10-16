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


//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    // Uncomment the following line to preserve selection between presentations.
//    // self.clearsSelectionOnViewWillAppear = NO;
//    
//    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//}

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
    
    // CODE NOT TESTED
    if ([self alertView:alertView clickedButtonAtIndex:alertView.cancelButtonIndex]) { // && add if new user
        // import contacts
        
        APAddressBook *addressBook = [[APAddressBook alloc] init];
        // don't forget to show some activity
        [addressBook loadContacts:^(NSArray *contacts, NSError *error)
        {
            // hide activity
            if (!error)
            {
                // do something with contacts array
                // if users in contacts have an account, add them as friends + display
                // make sure you store your own phone number at sign up and confirm it via text
            }
            else
            {
                // show error
            }
        }];

        
    }
    
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



//// should delete friends (+ remove relation) for selected cells - not tested
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
//    
////    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(userPressedDone)];
////    doneBarButtonItem.title = @"Delete";
////    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
//    
//    PFRelation *friendsRelation = [self.currentUser relationforKey:@"friendsRelation"];
//    PFUser *user = [self.friends objectAtIndex:indexPath.row];
//    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    
//    for(PFUser *friend in self.friends) {
//        if ([friend.objectId isEqualToString:user.objectId]) {
//            [self.friends removeObject:friend];
//            [friendsRelation removeObject:user];
//            break;
//        }
//    }
//    
//    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
//
//}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
