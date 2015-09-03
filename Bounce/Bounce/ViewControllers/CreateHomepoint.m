//
//  CreateHomepoint.m
//  bounce
//
//  Created by Robin Mehta on 7/14/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "CreateHomepoint.h"
#import "AddLocationScreenViewController.h"
#import "Utility.h"
#import "AddGroupUsersViewController.h"
#import "AppConstant.h"
#import "UIView+AutoLayout.h"
#import <QuartzCore/QuartzCore.h>

@implementation CreateHomepoint

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageAdded = NO;
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.backgroundColor = BounceRed;
    self.view.backgroundColor = BounceRed;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    UILabel *navLabel = [UILabel new];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.backgroundColor = [UIColor clearColor];
    navLabel.textAlignment = NSTextAlignmentCenter;
    navLabel.font = [UIFont fontWithName:@"Quicksand-Regular" size:20.0];
    self.navigationItem.titleView = navLabel;
    navLabel.text = @"CREATE HOMEPOINT";
    [navLabel sizeToFit];
    
    UIBarButtonItem *_cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked)];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];

    NSDictionary* barButtonItemAttributes =
    @{NSFontAttributeName:
        [UIFont fontWithName:@"AvenirNext-Regular" size:18.0f],
    NSForegroundColorAttributeName:
        [UIColor whiteColor]
    };
    
    [_cancel setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];

    self.navigationItem.leftBarButtonItem = _cancel;
    
    // PHOTO BUTTON
    
    _addPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addPhotoButton setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    [_addPhotoButton addTarget:self action:@selector(addPhotoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.overlay = [[UIView alloc] init];
    self.overlay.userInteractionEnabled = false;
    [_addPhotoButton addSubview:self.overlay];
    [self.overlay kgn_sizeToWidthAndHeightOfItem:_addPhotoButton];
    [self.overlay kgn_pinToTopEdgeOfSuperview];
    [self.overlay kgn_pinToLeftEdgeOfSuperview];

    self.editImageIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Homepoint-Camera"]];
    [_addPhotoButton addSubview:self.editImageIcon];
    [self.editImageIcon kgn_centerInSuperview];
    [self.editImageIcon kgn_sizeToWidthAndHeight:100.0];
    [self.view addSubview:_addPhotoButton];

    [_addPhotoButton kgn_pinToTopEdgeOfSuperview];
    [_addPhotoButton kgn_centerHorizontallyInSuperview];
    [_addPhotoButton kgn_pinToSideEdgesOfSuperview];
    [_addPhotoButton kgn_sizeToHeight:self.view.frame.size.height * 272/665.0];
    
    // TEXT FIELD
    
    _groupNameTextField = [UITextField new];
    _groupNameTextField.backgroundColor = [UIColor colorWithWhite:243/256.0 alpha:1.0];
    _groupNameTextField.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0];
    _groupNameTextField.placeholder = @"Name your homepoint";
    _groupNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _groupNameTextField.keyboardType = UIKeyboardTypeDefault;
    _groupNameTextField.returnKeyType = UIReturnKeyDone;
    _groupNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _groupNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _groupNameTextField.textAlignment = NSTextAlignmentLeft;
    _groupNameTextField.delegate = self;
    const CGFloat textfieldHeight = 53.0;
    _groupNameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15.0, textfieldHeight)];
    _groupNameTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_groupNameTextField];
    [_groupNameTextField kgn_positionBelowItem:_addPhotoButton withOffset:50.0];
    [_groupNameTextField kgn_centerHorizontallyInSuperview];
    [_groupNameTextField kgn_pinToSideEdgesOfSuperviewWithOffset:35.0];
    [_groupNameTextField kgn_sizeToHeight:textfieldHeight];
    
    UILabel *homepointHint = [[UILabel alloc] init];
    homepointHint.text = @"The best names are easily recognizable.";
    homepointHint.textColor = [UIColor colorWithWhite:0.0 alpha:0.36];
    homepointHint.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0];
    [self.view addSubview:homepointHint];
    [homepointHint kgn_pinToLeftEdgeOfSuperviewWithOffset:35.0];
    [homepointHint kgn_positionBelowItem:_groupNameTextField withOffset:10.0];
    
    _addLocationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _addLocationButton.layer.cornerRadius = 10.0;
    _addLocationButton.layer.borderWidth = 1.5;
    _addLocationButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    [_addLocationButton setTitle:@"Continue" forState:UIControlStateNormal];
    _addLocationButton.tintColor = [UIColor whiteColor];
    _addLocationButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18.0];
    _addLocationButton.titleLabel.textColor = [UIColor whiteColor];

    [_addLocationButton addTarget:self action:@selector(checkGroupNameValidation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addLocationButton];
    [_addLocationButton kgn_pinToBottomEdgeOfSuperviewWithOffset:40.0 + TAB_BAR_HEIGHT];
    [_addLocationButton kgn_centerHorizontallyInSuperview];
    [_addLocationButton kgn_pinToSideEdgesOfSuperviewWithOffset:35.0];
    [_addLocationButton kgn_sizeToHeight:textfieldHeight];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Navigation Bar
-(void) setBarButtonItemLeft:(NSString*) imageName {
    UIImage *menuImage = [UIImage imageNamed:imageName];
    self.navigationItem.leftBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(cancelButtonClicked)];
}

-(void)cancelButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.bounds = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barButtonItem;
}

//-(void)doneButtonClicked{
//    // will Create group with user location and navigate to add group users screen
//    [self checkGroupNameValidation];
//}

-(void)addPhotoButtonClicked {
    if (!_imageActionSheet) {
        self.imageActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Upload photo", @"Take photo", nil];
    }
    [self.imageActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation
{
    if (buttonIndex == 0) { // remove photo
        [self showPhotoPicker];
    }
    else if (buttonIndex == 1) { //upload photo
        [self showCameraPicker];
    }
    else if (buttonIndex == actionSheet.cancelButtonIndex) {
        // WHAT to do when cancel?
    }
}

#pragma mark - AddLocation screen
- (void) navigateToAddLocationScreen {
    @try {
        AddLocationScreenViewController *addLocationScreenViewController = [AddLocationScreenViewController new];
        addLocationScreenViewController.groupName = self.groupNameTextField.text;
        addLocationScreenViewController.homepointImage = self.addPhotoButton.imageView.image;
        [self.navigationController pushViewController:addLocationScreenViewController animated:YES];
    }
    @catch (NSException *exception) {
            NSLog(@"Exception %@", exception);
    }
}

- (void)groupNameExist:(BOOL)exist
{
    [[Utility getInstance] hideProgressHud];
    NSString *name = [self.groupNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([name length] == 0) {
        [[Utility getInstance] showAlertMessage:@"Make sure you enter a group name!"];
    }
    else if (exist) {
        NSLog(@"NOT UNIQUE GROUP NAME"); // write alert to try a different username
        [[Utility getInstance] showAlertMessage:@"This group name seems to be taken. Please choose another!"];
    }
    else {
//        [self getAllUsers];
//        } else {
        [self navigateToAddLocationScreen];
//        }
    }

}

#pragma mark - Get all user
- (void) getAllUsers
{
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        [[Utility getInstance] showProgressHudWithMessage:COMMON_HUD_LOADING_MESSAGE];
        [[ParseManager getInstance] setDelegate:self];
        [[ParseManager getInstance] getAllUsers];
    }
}

- (void) checkGroupNameValidation
{
    @try {
        self.groupNameTextField.text = [self.groupNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([self.groupNameTextField.text length] == 0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please give your homepoint a name!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
//        if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
//            [[Utility getInstance] showProgressHudWithMessage:@"checking to see if group name exists"];
//            [[ParseManager getInstance] isGroupNameExist:name];
//        } ///// THIS RUNS WAY TOO SLOW
        else if (!self.imageAdded) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please add a photo for your homepoint!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        else
            [self navigateToAddLocationScreen];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - Parse Manager Delegate
- (void)didloadAllObjects:(NSArray *)objects
{
    [[Utility getInstance] hideProgressHud];
    NSMutableArray *users  = [[NSMutableArray alloc] initWithArray:objects];
    PFUser *currentUser = [PFUser currentUser];
    // Add the current user to the first cell
    [users insertObject:currentUser atIndex:0];
    [self navigateToAddGroupUsersScreenWithUsers:([NSArray arrayWithArray:users])];
    
}

#pragma mark - AddLocation screen
- (void) navigateToAddGroupUsersScreenWithUsers:(NSArray *) users
{
    if (!self.imageAdded) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please add a photo for your homepoint!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self.groupNameTextField.text isEqualToString:@""] || self.groupNameTextField.text == nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please give your homepoint a name!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
    @try {
        AddGroupUsersViewController *addGroupUsersViewController = [AddGroupUsersViewController new];
        addGroupUsersViewController.groupName = self.groupNameTextField.text;
        addGroupUsersViewController.groupLocation = [[PFUser currentUser] objectForKey:PF_USER_LOCATION];
        addGroupUsersViewController.groupUsers = users;
        [self.navigationController pushViewController:addGroupUsersViewController animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
    }
}

- (void)didFailWithError:(NSError *)error {
    [[Utility getInstance] hideProgressHud];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 20;
}

- (void)cancelPressed {
    [self dismissViewControllerAnimated:false completion:nil];
}


#pragma mark - Camera picker

- (void)showPhotoPicker {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIAlertView *deviceNotFoundAlert = [[UIAlertView alloc] initWithTitle:@"Photo library is not available."
                                                                      message:@""
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Okay"
                                                            otherButtonTitles:nil];
        [deviceNotFoundAlert show];
    } else {
        UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
        photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        photoPicker.allowsEditing = NO;
        photoPicker.delegate = (id)self;
        [self presentViewController:photoPicker
                           animated:YES
                         completion:nil];
    }
}

- (void)showCameraPicker {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *deviceNotFoundAlert = [[UIAlertView alloc] initWithTitle:@"Camera is not available."
                                                                      message:@""
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Okay"
                                                            otherButtonTitles:nil];
        [deviceNotFoundAlert show];
    } else {
        UIImagePickerController *cameraPicker = [[UIImagePickerController alloc] init];
        cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraPicker.allowsEditing = NO;
        cameraPicker.delegate = (id)self;
        [self presentViewController:cameraPicker
                           animated:YES
                         completion:nil];
    }
}

- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToHeight:(float)height
{
    float oldHeight = sourceImage.size.height;
    float scaleFactor = height / oldHeight;
    
    float newHeight = oldHeight *scaleFactor;
    float newWidth = sourceImage.size.width * scaleFactor;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0);
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth:(float)width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0);
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - ImagePicker Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (image) {
        if (image.size.height > image.size.width) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please upload a landscape photo!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else {
             image = [self imageWithImage:image scaledToHeight:self.view.frame.size.width];
            self.editImageIcon.image = [UIImage imageNamed:@"Homepoint-Pencil"];
            [_addPhotoButton setImage:image forState:UIControlStateNormal];
            self.addPhotoButton.imageView.contentMode = UIViewContentModeScaleToFill;
            self.imageAdded = YES;
            self.overlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        }
    } else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Error uploading image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
