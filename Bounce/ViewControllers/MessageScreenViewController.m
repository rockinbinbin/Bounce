//
//  MessageScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "MessageScreenViewController.h"
#import "Utility.h"
#import "ChatListCell.h"
#import "AppConstant.h"
#import "RequestManger.h"
#import "HomeScreenViewController.h"
#import "UIViewController+AMSlideMenu.h"

@interface MessageScreenViewController ()
@end

@implementation MessageScreenViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    if (IS_IPAD) {
        self.verticalSpaceBetweenTableAndGenderButton.constant = 200;
        self.bottomSpaceToButtons.constant = 180;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingNotification:) name:@"SelectedStringNotification" object:nil];
    _distanceSelectButton.backgroundColor = LIGHT_SELECT_GRAY_COLOR;
    _durationSelectButton.backgroundColor = LIGHT_SELECT_GRAY_COLOR;

    self.selectedGroups = [NSMutableArray array];
    self.location_manager = [[CLLocationManager alloc] init];
    
    [self addArrowImageToButton:self.distanceSelectButton];
    [self addArrowImageToButton:self.durationSelectButton];
}

-(void) addArrowImageToButton:(UIButton*) selectButton{
    UIImageView *downArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_down_arrow"]];
    downArrow.contentMode = UIViewContentModeScaleToFill;
    downArrow.frame = CGRectMake(170, 16, 10, 10);
    downArrow.contentMode=UIViewContentModeScaleAspectFill;
    [selectButton addSubview:downArrow];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    [self disableSlidePanGestureForLeftMenu];
    // background
    self.title = @"New Message";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setBarButtonItemLeft:@"common_back_button"];
    self.navigationItem.title = @"contact nearby";
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Send"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(sendButtonClicked)];
    sendButton.tintColor = DEFAULT_COLOR;
    self.navigationItem.rightBarButtonItem = sendButton;
    
    @try {
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:@"Loading..." withView:self.view];
            [[ParseManager getInstance] setGetUserGroupsdelegate:self];
            [[ParseManager getInstance] getUserGroups];
            self.isDataLoaded = NO;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}

- (void)viewDidUnload {
    _distanceSelectButton = nil;
    _durationSelectButton = nil;
    [self setDistanceSelectButton:nil];
    [self setDurationSelectButton:nil];
    [super viewDidUnload];
}

- (void) incomingNotification:(NSNotification *)notification{
    NSString *wordSent = [notification object];
    if (self.isDistanceSent) {
        self.distance = wordSent;
    }
    else{
        self.duration = wordSent;
    }
}

#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName{
    UIImage *menuImage = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(backButtonClicked)];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}

-(void)sendButtonClicked{
    NSString *RadiusString = [self.distance stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *TimeString = [self.duration stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // INPUT ERROR MESSAGES
    if ([RadiusString length] == 0 || [TimeString length] == 0) {
        [[Utility getInstance] showAlertWithMessage:@"Please Enter a radius and time value!" andTitle:@"Oops!"];
    }
    else {
        
        int radius = [self getNumberInString:RadiusString];
        int time = [self getNumberInString:TimeString];
        
        for (int i = 0; i < self.selectedCells.count; i++) {
            if ([[self.selectedCells objectAtIndex:i] boolValue]) { // if selected
                [self.selectedGroups addObject:[self.groups objectAtIndex:i]];
            }
        }
        
        if ([self.selectedGroups count]) {
            [self creatMessageRequestToSelectedGroup:self.selectedGroups withRadius:radius andTimeAllocated:time];
        }
        else {
            UIAlertView *zerolength = [[UIAlertView alloc] initWithTitle:@"yo!"
                                                                 message:@"Please check at least one group!"
                                                                delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [zerolength show];
        }

    }
}

-(void)backButtonClicked{
    //TODO: navigate to the last view controller.
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void) creatMessageRequestToSelectedGroup:(NSArray *) selectedGroups withRadius:(int) radius andTimeAllocated:(int) timeAllocated
{
    @try {
        NSString *genderMatching;
        if ([self.groupGenderSegment selectedSegmentIndex] == 0) {
            genderMatching = ALL_GENDER;
        } else if ([self.groupGenderSegment selectedSegmentIndex] == 1) {
            PFUser* u = [PFUser currentUser];
            genderMatching = u[PF_GENDER];
        }
        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
            [[Utility getInstance] showProgressHudWithMessage:COMMON_HUD_SEND_MESSAGE];
            [[RequestManger getInstance] setCreateRequestDelegate:self];
            [[RequestManger getInstance] createrequestToGroups:self.selectedGroups andGender:genderMatching withinTime:timeAllocated andInRadius:radius];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

// hides keyboard when user clicks return
- (BOOL) textFieldShouldReturn: (UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)isNumeric:(NSString*)inputString{
    BOOL isValid = NO;
    NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
    isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    return isValid;
}

#pragma mark - Navigation
-(int) getNumberInString:(NSString*) string{
    NSString *numberString;
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    // Throw away characters before the first number.
    [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
    
    // Collect numbers.
    [scanner scanCharactersFromSet:numbers intoString:&numberString];
    
    // Result.
    int number = (int)[numberString integerValue];
    NSLog(@"%i", number);
    return number;
}

- (IBAction)cancelButtonPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)genderSegmentClicked:(id)sender {
    if ([self.groupGenderSegment selectedSegmentIndex] == 0) {
        NSLog(@"all genders!");
    } else if ([self.groupGenderSegment selectedSegmentIndex] == 1) {
        NSLog(@"same genders!");
    }
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"ChatListCell";
    ChatListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
        cell = (ChatListCell *)[nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.roundedView.hidden = YES;
    cell.numOfMessagesLabel.text = @"0";
    
    if ([[self.selectedCells objectAtIndex:indexPath.row] boolValue]) {
        cell.nearbyLabel.hidden = YES;
        cell.numOfFriendsInGroupLabel.hidden = YES;
        cell.iconImageView.hidden = NO;
        cell.iconImageView.image = [UIImage imageNamed:@"common_checkmark_icon"];
    }
    else{
        cell.iconImageView.hidden = YES;
        cell.iconImageView.image = nil;
        cell.iconImageView.hidden = NO;
        if (self.isDataLoaded) {
            cell.groupDistanceLabel.hidden = NO;
            cell.numOfFriendsInGroupLabel.hidden = NO;
            cell.nearbyLabel.hidden = NO;
        }
        else{
            cell.groupDistanceLabel.hidden = YES;
            cell.numOfFriendsInGroupLabel.hidden = YES;
            cell.nearbyLabel.hidden = YES;
        }
    }

    if (IS_IPAD) {
        cell.groupNameLabel.font=[cell.groupNameLabel.font fontWithSize:20];
        cell.groupDistanceLabel.font=[cell.groupDistanceLabel.font fontWithSize:12];
    }

    for ( UIView* view in cell.contentView.subviews )
    {
        view.backgroundColor = [ UIColor clearColor ];
    }
    
    cell.groupNameLabel.text = [[self.groups objectAtIndex:indexPath.row] objectForKey:PF_GROUPS_NAME];
    cell.groupDistanceLabel.text = [NSString stringWithFormat:DISTANCE_MESSAGE, [[self.distanceToUserLocation objectAtIndex:indexPath.row] doubleValue]];
    cell.numOfFriendsInGroupLabel.text = [NSString stringWithFormat:@"%@",[self.nearUsers objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectedCells.count > 0) {
        if ([[self.selectedCells objectAtIndex:indexPath.row] boolValue]) {
            [self.selectedCells replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
        }
        else{
            [self.selectedCells replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
        }
        [self.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    [self rel];
}


-(void)rel{
    //    [dropDown release];
    _dropDown = nil;
}

- (IBAction)distanceSelectButtonClicked:(id)sender{
    self.isDistanceSent = true;
    NSArray * arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@"People within 100 feets", @"People within 300 feets", @"People within 500 feets",nil];
    if(_dropDown == nil) {
        CGFloat f = 80;
        _dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :nil :@"down"];
        _dropDown.delegate = self;
    }
    else {
        [_dropDown hideDropDown:sender];
        [self rel];
    }
}

- (IBAction)durationSelectButtonClicked:(id)sender{
    self.isDistanceSent = false;
    NSArray * arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@"Expires in 15 minutes", @"Expires in 20 minutes", @"Expires in 60 minutes", nil];
    if(_dropDown == nil) {
        CGFloat f = 80;
        _dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :nil :@"down"];
        _dropDown.delegate = self;
    }
    else {
        [_dropDown hideDropDown:sender];
        [self rel];
    }
}


#pragma mark - Parse LoadGroups delegate
- (void)didLoadUserGroups:(NSArray *)groups WithError:(NSError *)error
{
    @try {
        if (error) {
            [[Utility getInstance] hideProgressHud];
            self.isDataLoaded = YES;
        }else{
            if(!self.groups)
            {
                self.groups = [[NSMutableArray alloc] init];
            }
            self.groups = [NSMutableArray arrayWithArray:groups];
            self.selectedCells = [[NSMutableArray alloc] init];
            for (int i = 0; i < self.groups.count; i++) {
                [self.selectedCells addObject:[NSNumber numberWithBool:NO]];
            }
            // calculate the near users in each group
            // calcultae the distance to the group
            self.nearUsers = [[NSMutableArray alloc] init];
            self.distanceToUserLocation = [[NSMutableArray alloc] init];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (PFObject *group in groups) {
                    [self.nearUsers addObject:[NSNumber numberWithInteger:[[ParseManager getInstance] getNearUsersNumberInGroup:group]]];
                    [self.distanceToUserLocation addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    [[Utility getInstance] hideProgressHud];
                    self.isDataLoaded = YES;
                    [self.tableView reloadData];
                });
            });
        }
    }
    @catch (NSException *exception) {
        
    }
}
- (void)didLoadGroups:(NSArray *)groups withError:(NSError *)error
{
    @try {
        
        if (error) {
            [[Utility getInstance] hideProgressHud];
            self.isDataLoaded = YES;
        }else{
            if(!self.groups)
            {
                self.groups = [[NSMutableArray alloc] init];
            }
            self.groups = [NSMutableArray arrayWithArray:groups];
            // calculate the near users in each group
            // calcultae the distance to the group
            self.nearUsers = [[NSMutableArray alloc] init];
            self.distanceToUserLocation = [[NSMutableArray alloc] init];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (PFObject *group in groups) {
                    [self.nearUsers addObject:[NSNumber numberWithInteger:[[ParseManager getInstance] getNearUsersNumberInGroup:group]]];
                    [self.distanceToUserLocation addObject:[NSNumber numberWithDouble:[[ParseManager getInstance] getDistanceToGroup:group]]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI on the main thread.
                    [[Utility getInstance] hideProgressHud];
                    self.isDataLoaded = YES;
                    [self.tableView reloadData];
                });
            });
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}

#pragma mark - Request Manager Create Request delegate
- (void)didCreateRequestWithError:(NSError *)error
{
    @try {
        [[Utility getInstance] hideProgressHud];
        if (error) {
            //
            [[Utility getInstance] showAlertMessage:FAILURE_SEND_MESSAGE];
        }else{
            // MOVE TO HOME
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
    }
}
@end
