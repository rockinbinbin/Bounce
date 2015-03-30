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

@interface EditGroupsViewController ()

@end

@implementation EditGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBarButtonItemLeft:@"common_plus_icon"];
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
    //TODO: Add the add button action
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
    
    // make the circularView rounder
    cell.circularView.layer.cornerRadius = cell.circularView.frame.size.height / 2;
    cell.circularView.clipsToBounds = YES;
    cell.circularView.layer.borderWidth = 3.0f;
    cell.circularView.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.circularView.backgroundColor = DEFAULT_COLOR;
    
    // rounded view on the left
    CGRect userOnlineFrame = CGRectMake(cell.circularView.frame.origin.x + 48, cell.circularView.frame.origin.y + 8, 20, 20);
    UIView* roundedView = [[UIView alloc] initWithFrame: userOnlineFrame];
    roundedView.layer.cornerRadius = 10;
    roundedView.layer.masksToBounds = YES;
    roundedView.backgroundColor = [UIColor redColor];
    
    // number of messages for the group
    UILabel *numOfMessagesLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5, 0, 30, 20)];
    numOfMessagesLabel.textAlignment = NSTextAlignmentCenter;
    [numOfMessagesLabel setTextColor:[UIColor whiteColor]];
    [numOfMessagesLabel setBackgroundColor:[UIColor clearColor]];
    [numOfMessagesLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
    numOfMessagesLabel.text = @"44";
    [roundedView addSubview:numOfMessagesLabel];
    [cell addSubview:roundedView];
    
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
