//
//  EditGroupsViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/30/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "EditGroupsViewController.h"
#import "AppConstant.h"
#import "ChatListCell.h"

#import "AddHomePointViewController.h"
@interface EditGroupsViewController ()

@end

@implementation EditGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBarButtonItemLeft:@"common_plus_icon_red"];
    self.navigationItem.title = @"homepoints";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(doneButtonClicked)];
    doneButton.tintColor = DEFAULT_COLOR;
    self.navigationItem.rightBarButtonItem = doneButton;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName{
    UIImage *menuImage = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(addButtonClicked)];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}

-(void)addButtonClicked{
    AddHomePointViewController* addHomePointViewController = [[AddHomePointViewController alloc] initWithNibName:@"AddHomePointViewController" bundle:nil];
    [self.navigationController pushViewController:addHomePointViewController animated:YES];
}

-(void)doneButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"ChatListCell";
    ChatListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
        cell = (ChatListCell *)[nib objectAtIndex:0];
    }
    cell.numOfMessagesLabel.text = @"8";

    // filling the cell data
    cell.groupNameLabel.text = @"Group 1";
    cell.groupDistanceLabel.text = @"2.1 miles away";
    cell.numOfFriendsInGroupLabel.text = @"44";
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSLog(@"%li index is deleted !", (long)indexPath.row);
        //[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}



@end
