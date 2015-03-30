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

@interface AddHomePointViewController ()

@end

@implementation AddHomePointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBarButtonItemLeft:@"common_close_icon"];
    self.navigationItem.title = @"add homepoint";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(doneButtonClicked)];
    doneButton.tintColor = DEFAULT_COLOR;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    
//    [[self.groupPrivacySegmentedControl.subviews objectAtIndex:1] setBackgroundColor:DEFAULT_COLOR];

    //setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
//    [[self.groupPrivacySegmentedControl.subviews objectAtIndex:0] setBackgroundColor:[UIColor whiteColor]];
//    [[self.groupPrivacySegmentedControl.subviews objectAtIndex:1] setTitleTextAttributes:@{NSForegroundColorAttributeName : DEFAULT_COLOR} forState:UIControlStateSelected];
    self.addLocationButton.backgroundColor = LIGHT_BLUE_COLOR;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)cancelButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneButtonClicked{
    //TODO: Go to the users screen to add them in the group
//    AddHomePointViewController* addHomePointViewController = [[AddHomePointViewController alloc] initWithNibName:@"AddHomePointViewController" bundle:nil];
//    [self.navigationController pushViewController:addHomePointViewController animated:YES];
}

- (IBAction)segmentedControlClicked:(id)sender {
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
    cell.numOfMessagesLabel.hidden = YES;
    cell.numOfFriendsInGroupLabel.hidden = YES;
    cell.nearbyLabel.hidden = YES;
    cell.roundedView.hidden = YES;
    cell.groupNameLabel.font=[cell.groupNameLabel.font fontWithSize:16];
    cell.groupDistanceLabel.font=[cell.groupDistanceLabel.font fontWithSize:10];

    cell.circularViewWidth.constant = 40;
    cell.circularViewHeight.constant = 40;
    cell.circularView.layer.cornerRadius = 20;
    cell.circularView.clipsToBounds = YES;
    cell.circularView.layer.borderWidth = 0;
    cell.circularView.layer.borderColor = [UIColor whiteColor].CGColor;


    cell.iconImageView.image = [UIImage imageNamed:@"common_checkmark_icon"];
    for ( UIView* view in cell.contentView.subviews )
    {
        view.backgroundColor = [ UIColor clearColor ];
    }

    cell.contentView.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0f];

    // filling the cell data
    cell.groupNameLabel.text = @"Group 1";
    cell.groupDistanceLabel.text = @"2.1 miles away";
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
    return 50;
}

@end
