//
//  MessageScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "MessageScreenViewController.h"
#import "SelectGroupsTableViewController.h"
#import "Utility.h"
#import "ChatListCell.h"
#import "AppConstant.h"

@interface MessageScreenViewController ()
@end

@implementation MessageScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingNotification:) name:@"SelectedStringNotification" object:nil];
//
//    UIBarButtonItem *CancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
//    
//    self.navigationItem.leftBarButtonItem = CancelButton;
//    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    [self.view addGestureRecognizer:gestureRecognizer];
    _distanceSelectButton.backgroundColor = LIGHT_SELECT_GRAY_COLOR;
    _durationSelectButton.backgroundColor = LIGHT_SELECT_GRAY_COLOR;

    
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
    
    int radius = [self getNumberInString:RadiusString];
    int time = [self getNumberInString:TimeString];
    
    // INPUT ERROR MESSAGES
    if ([RadiusString length] == 0 || [TimeString length] == 0) {
        [[Utility getInstance] showAlertWithMessage:@"Please Enter a radius and time value!" andTitle:@"Oops!"];
    }
    else {
        
        SelectGroupsTableViewController *controller = [[SelectGroupsTableViewController alloc] init];
        controller.radius = radius;
        controller.timeAllocated = time;
        if ([self.groupGenderSegment selectedSegmentIndex] == 0) {
            controller.genderFilter = @"All";
        } else if ([self.groupGenderSegment selectedSegmentIndex] == 1) {
            PFUser* u = [PFUser currentUser];
            controller.genderFilter = u[@"Gender"]; // Male or Female
        }
        [self.navigationController pushViewController:controller animated:YES];
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
    return 4;//[self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"ChatListCell";
    ChatListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
        cell = (ChatListCell *)[nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.numOfMessagesLabel.text = @"0";
    // filling the cell data
    //    cell.groupNameLabel.text = @"Group 1";
    //    cell.groupDistanceLabel.text = @"2.1 miles away";
    //    cell.numOfFriendsInGroupLabel.text = @"44";
    
    cell.groupNameLabel.text = @"groupNameLabel"; //[[self.groups objectAtIndex:indexPath.row] objectForKey:PF_GROUPS_NAME];
    cell.groupDistanceLabel.text = @"groupDistanceLabel";// [NSString stringWithFormat:DISTANCE_MESSAGE, [[distanceToUserLocation objectAtIndex:indexPath.row] doubleValue]];
    cell.numOfFriendsInGroupLabel.text = @"numOfFriendsInGroupLabel";// [NSString stringWithFormat:@"%@",[nearUsers objectAtIndex:indexPath.row]];
//    NSLog(@"near users %@", [nearUsers objectAtIndex:indexPath.row]);
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (IBAction)selectClicked:(id)sender {
    NSArray * arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@"Male", @"Female",nil];
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
    arr = [NSArray arrayWithObjects:@"People within 50 miles", @"People within 100 miles",nil];
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
    arr = [NSArray arrayWithObjects:@"Expires in 10 minutes", @"Expires in 20 minutes",nil];
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

@end
