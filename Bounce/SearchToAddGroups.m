//
//  SearchToAddGroups.m
//  bounce
//
//  Created by Robin Mehta on 8/16/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "SearchToAddGroups.h"
#import "UIView+AutoLayout.h"
#import "membersCell.h"
#import "Constants.h"
#import "AppConstant.h"

#define ResultsTableView self.searchResultsTableViewController.tableView
#define Identifier @"Cell"

@interface SearchToAddGroups ()

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultsTableViewController;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) PFObject *currentGroup;
@property (nonatomic) BOOL shouldAdd;

@end

@implementation SearchToAddGroups

- (void)viewDidLoad {
        [super viewDidLoad];
    
        [self setBarButtonItemLeft:@"common_back_button"];
        self.searchResults = [NSMutableArray new];
    self.index = -1;
    self.shouldAdd = NO;
    
        UILabel *navLabel = [UILabel new];
        navLabel.textColor = [UIColor whiteColor];
        navLabel.backgroundColor = [UIColor clearColor];
        navLabel.textAlignment = NSTextAlignmentCenter;
        navLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
        self.navigationItem.titleView = navLabel;
        navLabel.text = @"Search for Homepoints";
        [navLabel sizeToFit];
    
        UITableView *searchResultsTableView = [[UITableView alloc] initWithFrame:self.tableView.frame];
        searchResultsTableView.dataSource = self;
        searchResultsTableView.delegate = self;
    
        self.searchResultsTableViewController = [[UITableViewController alloc] init];
        self.searchResultsTableViewController.tableView = searchResultsTableView;
    
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsTableViewController];
        self.searchController.searchResultsUpdater = self;
        self.searchController.delegate = self;
    
        self.searchController.searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
        self.tableView.tableHeaderView = self.searchController.searchBar;
    
        self.definesPresentationContext = YES;
}

- (void)viewDidAppear:(BOOL)animated {
        [super viewDidAppear:animated];
}

#pragma mark - Util methods

-(void) setBarButtonItemLeft:(NSString*) imageName {
        UIImage *menuImage = [UIImage imageNamed:imageName];
        self.navigationItem.leftBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(cancelButtonClicked)];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action {

    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
        return barButtonItem;
}

- (void)cancelButtonClicked {
   [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View Data Source
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
                    return 0;
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
            }
    
        UIImage *img = [UIImage imageNamed:@"redPlusWithBorder"];
        [cell.iconView setImage:img forState:UIControlStateNormal];
    
        if (indexPath.row == self.index) {
                [cell.iconView setImage:nil forState:UIControlStateNormal];
                cell.requestAdded.text = @"Request sent!";
           }
    
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
        return cell;
    }

- (void) addGroup:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [ResultsTableView indexPathForRowAtPoint:buttonPosition];
        if (indexPath != nil) {
                    self.currentGroup = [self.searchResults objectAtIndex:indexPath.row];
                    [[ParseManager getInstance] setGetTentativeUsersDelegate:self];
                    [[ParseManager getInstance] getTentativeUsersFromGroup:self.currentGroup];
               if (self.index != indexPath.row) {
                        self.index = indexPath.row;
                   self.shouldAdd = YES;
                    }
                else {
                        self.index = -1;
                    self.shouldAdd = NO;
                    }
                [ResultsTableView reloadData];
           }
}

- (void)didLoadTentativeUsers:(NSArray *)tentativeUsers {
        [[ParseManager getInstance] addTentativeUserToGroup:self.currentGroup withExistingTentativeUsers:tentativeUsers];
        if (self.shouldAdd) {
               [[ParseManager getInstance] addTentativeUserToGroup:self.currentGroup withExistingTentativeUsers:tentativeUsers];
            }
        else {
                [[ParseManager getInstance] removeUser:[PFUser currentUser] fromTentativeGroup:self.currentGroup];
            }
    
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        //[tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 100;
}

#pragma mark - Search Results Updating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.index = -1;
    UISearchBar *searchBar = searchController.searchBar;
    if (searchBar.text.length > 0) {
               NSString *text = searchBar.text;
        
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFObject *group, NSDictionary *bindings) {
                       NSRange range = [[group objectForKey:@"groupName"] rangeOfString:text options:NSCaseInsensitiveSearch];
                    
                        return range.location != NSNotFound;
                    }];
        
                NSArray *searchResults = [self.allGroups filteredArrayUsingPredicate:predicate];
                self.searchResults = searchResults;
        
                [self.searchResultsTableViewController.tableView reloadData];
            }
    }


@end