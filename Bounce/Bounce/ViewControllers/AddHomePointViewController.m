//
//  AddHomePointViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "AddHomePointViewController.h"
#import "AppConstant.h"
#import "ChatListCell.h"
#import "AddGroupUsersViewController.h"
#import <Parse/Parse.h>
#import "GroupsListViewController.h"
#import "Utility.h"
#import "Constants.h"
#import "AddGroupUsersViewController.h"
#import "AddLocationScreenViewController.h"
#import "CreateHomepoint.h"
#import "UIView+AutoLayout.h"
#import "homepointListCell.h"
#import "SearchToAddGroups.h"
#import "membersCell.h"
#import "CAPSPageMenu.h"

#define ResultsTableView self.searchResultsTableViewController.tableView
#define Identifier @"Cell"

@interface AddHomePointViewController ()

@property (nonatomic) NSInteger cellIndex;
//////////////
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultsTableViewController;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) PFObject *currentGroup;
@property (nonatomic) BOOL shouldAdd;

@end

@implementation AddHomePointViewController
{
    NSMutableArray *groups;
    NSMutableArray *groupsDistance;
    NSMutableArray *userJoinedGroups;
    NSInteger selectedIndex;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.allGroups = [NSArray new];
    self.searchResults = [NSMutableArray new];
    self.index = -1;
    self.shouldAdd = NO;
    
    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:20];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"Add Homepoint";
    [navLabel sizeToFit];
    
    [self setBarButtonItemLeft:@"common_back_button"];
    
    UIBarButtonItem *createButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"createIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(createButtonClicked)];
    
    createButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = createButton;
    
    UITableView *searchResultsTableView = [[UITableView alloc] initWithFrame:self.tableView.frame];
    searchResultsTableView.dataSource = self;
    searchResultsTableView.delegate = self;
    
    self.searchResultsTableViewController = [[UITableViewController alloc] init];
    self.searchResultsTableViewController.tableView = searchResultsTableView;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsTableViewController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    
//    UIView *searchContainerView = [UIView new];
//    [searchContainerView addSubview:self.searchController.searchBar];
//    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchContainerView];
//    self.navigationItem.rightBarButtonItem = searchBarItem;
//    CGRect bounds = self.navigationController.view.frame;
//    bounds= CGRectMake(120, 0, bounds.size.width-120, 44);
//    [searchContainerView setFrame:bounds];
    
    self.searchController.searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    self.tableView.tableHeaderView = self.searchController.searchBar;
//    self.navigationItem.titleView = self.searchController.searchBar;
    self.searchController.searchBar.placeholder = @"Search by street, town, or city";
    
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
//    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 320.0, 44.0)];
//    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 310.0, 44.0)];
//    searchBarView.autoresizingMask = 0;
//    searchBar.delegate = self;
//    searchBar.placeholder = @"Search for a homepoint's name or address";
//    [searchBarView addSubview:searchBar];
//    self.navigationItem.titleView = searchBarView;
    
    self.definesPresentationContext = YES;
}

-(void)createButtonClicked {
//    [[Utility getInstance] showProgressHudWithMessage:@"Loading"];
//    [[ParseManager getInstance] setGetAllOtherGroupsDelegate:self];
//    [[ParseManager getInstance] getAllOtherGroupsForCurrentUser];
    
    @try {
        CreateHomepoint *createhomepoint = [CreateHomepoint new];
        [self.navigationController pushViewController:createhomepoint animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[Utility getInstance] showProgressHudWithMessage:@"Loading"];
    [[ParseManager getInstance] setGetAllOtherGroupsDelegate:self];
    [[ParseManager getInstance] getAllOtherGroupsForCurrentUser];
    [[ParseManager getInstance] setGetTentativeUsersDelegate:self];
    [[ParseManager getInstance] setUpdateGroupDelegate:self];
    [self loadGroups];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - load groups
- (void) loadGroups
{
    @try {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Loading..." withView:self.view];
            [[ParseManager getInstance] setLoadGroupsdelegate:self];
            [[ParseManager getInstance] getCandidateGroupsForCurrentUser];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
#pragma mark - Parse Loading Groups Manager Delegate
- (void)didLoadGroups:(NSArray *)objects withError:(NSError *)error
{
    @try {
        [[Utility getInstance] hideProgressHud];
        if (!error) {
            groups = [[NSMutableArray alloc] initWithArray:objects];
            groupsDistance = [[NSMutableArray alloc] init];
            userJoinedGroups = [[NSMutableArray alloc] init];
            self.homepointImages = [NSMutableArray new];
            
            for (PFObject *group in groups) {
                [groupsDistance addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                [userJoinedGroups addObject:[NSNumber numberWithBool:NO]];
                
                if ([group valueForKey:PF_GROUP_IMAGE]) {
                    [self.homepointImages addObject:[group valueForKey:PF_GROUP_IMAGE]];
                }
            }
            [[Utility getInstance] hideProgressHud];
            [self.tableView reloadData];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName{
    UIImage *menuImage = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(cancelButtonClicked)];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}

- (void)didLoadAllOtherGroups:(NSArray *)allGroups {
    [[Utility getInstance] hideProgressHud];
    self.allGroups = allGroups;
//        SearchToAddGroups *searchVC = [SearchToAddGroups new];
//        searchVC.allGroups = allGroups;
//    [self.navigationController pushViewController:searchVC animated:YES];
}

-(void)cancelButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:ResultsTableView]) {
        if (self.searchResults) {
            return self.searchResults.count;
        } else {
            return 0;
        }
    } else {
        return [groups count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = Identifier;
    membersCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [membersCell new];
    }
    
    NSString *text;
    if ([tableView isEqual:ResultsTableView]) {
        text = [self.searchResults[indexPath.row] objectForKey:@"groupName"];
        
        UIImage *img = [UIImage imageNamed:@"redPlusWithBorder"];
        [cell.iconView setImage:img forState:UIControlStateNormal];
        cell.iconView.tag = indexPath.row;
        
        if (indexPath.row == self.index) {
            [cell.iconView setImage:nil forState:UIControlStateNormal];
            cell.requestAdded.text = @"Request sent!";
        }
        
        cell.address.text = [self.searchResults[indexPath.row] objectForKey:@"Address"];
        
        [cell.iconView addTarget:self action:@selector(addGroup:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.name.text = text;
        PFObject *hp = [self.searchResults objectAtIndex:indexPath.row];
        PFFile *file = [hp objectForKey:PF_GROUP_IMAGE];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                cell.profileImage.image = image;
            }
        }];
    }
    else {
        text = [groups[indexPath.row] objectForKey:@"groupName"];
        
        UIImage *img = [UIImage imageNamed:@"redPlusWithBorder"];
        [cell.iconView setImage:img forState:UIControlStateNormal];
        cell.iconView.tag = indexPath.row;
        
        if (indexPath.row == self.index) {
            [cell.iconView setImage:nil forState:UIControlStateNormal];
            cell.requestAdded.text = @"Request sent!";
        }
        
        cell.address.text = [groups[indexPath.row] objectForKey:@"Address"];
        
        [cell.iconView addTarget:self action:@selector(addGroup:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.name.text = text;
        PFObject *hp = [groups objectAtIndex:indexPath.row];
        PFFile *file = [hp objectForKey:PF_GROUP_IMAGE];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                cell.profileImage.image = image;
            }
        }];
    }
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if ([[userJoinedGroups objectAtIndex:indexPath.row]boolValue]) {
//        // remove current user from the selected group
//        [self deleteUserFromGroup:indexPath.row];
//    } else {
//        // add current user to the selected group
//        [self addUserToGroup:indexPath.row];
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - Add User to selected group

- (void) addGroup:(id)sender {
    
    UIButton *senderButton = (UIButton *)sender;
    NSIndexPath *path = [NSIndexPath indexPathForRow:senderButton.tag inSection:0];
    
    if ([self.searchResults count]) {
    if (path != nil) {
        self.currentGroup = [self.searchResults objectAtIndex:path.row];
        [[ParseManager getInstance] setGetTentativeUsersDelegate:self];
        [[ParseManager getInstance] getTentativeUsersFromGroup:self.currentGroup];
        if (self.index != path.row) {
            self.index = path.row;
            self.shouldAdd = YES;
        }
        else {
            self.index = -1;
            self.shouldAdd = NO;
        }
        [ResultsTableView reloadData];
    }
    }
    else {
        if (path != nil) {
            self.currentGroup = [groups objectAtIndex:path.row];
            [[ParseManager getInstance] setGetTentativeUsersDelegate:self];
            [[ParseManager getInstance] getTentativeUsersFromGroup:self.currentGroup];
            if (self.index != path.row) {
                self.index = path.row;
                self.shouldAdd = YES;
            }
            else {
                self.index = -1;
                self.shouldAdd = NO;
            }
            [self.tableView reloadData];
        }
    }
}

//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
//{
//    if (buttonIndex == 0) {
//        [self requestToJoin];
//    }
//}
//
//- (void) addUserToGroup:(NSInteger) index
//{
//    self.cellIndex = index;
//    if (!_imageActionSheet) {
//        self.imageActionSheet = [[UIActionSheet alloc] initWithTitle:@"A member of this homepoint will have to approve your request."  delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Request to join", nil];
//        }
//    [self.imageActionSheet showInView:self.view];
//   
//}
//
//-(void)requestToJoin {
//    if ([self.searchResults count]) {
//        PFObject *group = [self.searchResults objectAtIndex:self.cellIndex];
//        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
//            [[Utility getInstance] showProgressHudWithMessage:[NSString stringWithFormat:@"Request sent to %@", [group objectForKey:PF_GROUPS_NAME]] withView:self.view];
//            selectedIndex = self.cellIndex;
//            [[ParseManager getInstance] setGetTentativeUsersDelegate:self];
//            [[ParseManager getInstance] getTentativeUsersFromGroup:group]; // this adds user to tentative list
//        }
//    }
//    else {
//        PFObject *group = [groups objectAtIndex:self.cellIndex];
//        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
//            [[Utility getInstance] showProgressHudWithMessage:[NSString stringWithFormat:@"Request sent to %@", [group objectForKey:PF_GROUPS_NAME]] withView:self.view];
//            selectedIndex = self.cellIndex;
//            [[ParseManager getInstance] setGetTentativeUsersDelegate:self];
//            [[ParseManager getInstance] getTentativeUsersFromGroup:group]; // this adds user to tentative list
//        }
//    }
//}

- (void)didLoadTentativeUsers:(NSArray *)tentativeUsers {
    [[Utility getInstance] hideProgressHud];
    if ([self.searchResults count]) {
        [[ParseManager getInstance] addTentativeUserToGroup:[self.searchResults objectAtIndex:self.cellIndex] withExistingTentativeUsers:tentativeUsers];
    }
    else {
        [[ParseManager getInstance] addTentativeUserToGroup:[groups objectAtIndex:self.cellIndex] withExistingTentativeUsers:tentativeUsers];
    }
}

#pragma mark - Delete user from selected group
- (void) deleteUserFromGroup:(NSInteger) index
{
    @try {
        PFObject *group = [groups objectAtIndex:index];
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:[NSString stringWithFormat:@"removed from %@", [group objectForKey:PF_GROUPS_NAME]] withView:self.view];
            selectedIndex = index;
            [[ParseManager getInstance] getTentativeUsersFromGroup:group];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Parse Manager Update Group delegate
- (void)didRemoveUserFromGroup:(BOOL)succeed
{
    [[Utility getInstance] hideProgressHud];
    if (succeed) {
        // update group cell
        [userJoinedGroups insertObject:[NSNumber numberWithBool:NO] atIndex:selectedIndex];
        [self updateRowAtIndex:selectedIndex];
    }
}

- (void)didAddUserToGroup:(BOOL)succeed
{
    [[Utility getInstance] hideProgressHud];
    if (succeed) {
        // update group cell
        [userJoinedGroups insertObject:[NSNumber numberWithBool:YES] atIndex:selectedIndex];
        [self updateRowAtIndex:selectedIndex];
    }
}

#pragma mark - update Row
- (void) updateRowAtIndex:(NSInteger) index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

#pragma mark - Parse Manager Delegate
- (void)didloadAllObjects:(NSArray *)objects
{
    [[Utility getInstance] hideProgressHud];
    NSMutableArray *users  = [[NSMutableArray alloc] initWithArray:objects];
    PFUser *currentUser = [PFUser currentUser];
    // Add the current user to the first cell
    [users insertObject:currentUser atIndex:0];
}
- (void)didFailWithError:(NSError *)error
{
    [[Utility getInstance] hideProgressHud];
}

#pragma mark - Search Results Updating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.index = -1;
    UISearchBar *searchBar = searchController.searchBar;
    if (searchBar.text.length > 0) {
        NSString *text = searchBar.text;
        
//        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFObject *group, NSDictionary *bindings) {
//            NSRange range = [[group objectForKey:@"groupName"] rangeOfString:text options:NSCaseInsensitiveSearch];
//            return range.location != NSNotFound;
//        }];
        
        NSPredicate *addressPredicate = [NSPredicate predicateWithBlock:^BOOL(PFObject *group, NSDictionary *bindings) {
            NSRange range = [[group objectForKey:@"Address"] rangeOfString:text options:NSCaseInsensitiveSearch];
            return range.location != NSNotFound;
        }];
        
        //NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate, addressPredicate]];
        
        NSArray *searchResults = [self.allGroups filteredArrayUsingPredicate:addressPredicate];
        
        self.searchResults = searchResults;
        [self.searchResultsTableViewController.tableView reloadData];
    }
}

@end
