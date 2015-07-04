//
//  LeftMenuTVC.m
//  testProject
//
//  Created by artur on 2/14/14.
//  Copyright (c) 2014 artur. All rights reserved.
//

#import "SlideMenuLeftTableViewController.h"
#import "HomeScreenViewController.h"
#import "RequestsViewController.h"
#import "Constants.h"
#import "AppConstant.h"
#import <ParseManager.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import "SlideMenuViewController.h"
#import "SettingsViewController.h"
#import "Terms_of_Use_ViewController.h"
#import "Privacy_Policy_ViewController.h"
#import "bounce-Swift.h"

#define Chats_Section 1
#define Home_section 0
#define Settings_Section 2
#define Terms_Section 3
#define Privacy_Section 4

@interface SlideMenuLeftTableViewController ()

@end

@implementation SlideMenuLeftTableViewController
{
    UIActionSheet *imageActionSheet;
    UIImage* profileImage;
    NSInteger activeChatNumber;
    UINavigationController *homeNavigationViewController;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.mainView.bounds = CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y, 400, self.mainView.frame.size.height);
    self.MainViewWidth.constant = SIDE_MENU_WIDTH;
    [[self.navigationController navigationBar] setHidden:YES];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor darkGrayColor];
    // Initilizing data souce
    self.tableData = [@[@"", @"Chat", @"Settings", @"Terms of Use", @"Privacy Policy"] mutableCopy];
    [self setProfileImage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatNumber:) name:@"UpdateChatNumber" object:nil];
}

-(void) viewWillAppear:(BOOL)animated{
    self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.frame.size.height / 2;
    self.userProfileImageView.clipsToBounds = YES;
    self.userProfileImageView.layer.borderWidth = 3.0f;
    self.userProfileImageView.layer.borderColor = BounceRed.CGColor;
//    [self setProfileImage];
    [self setUserNameAndLocationAtCell];
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == Home_section) {
        return 0;
    }
    return 40;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.backgroundColor = [UIColor darkGrayColor];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor darkGrayColor];
    [cell setSelectedBackgroundView:bgColorView];

    cell.textLabel.textColor = [UIColor whiteColor];
     
    int imageYPosition = cell.frame.origin.y + 20;
    
    if (indexPath.row == Chats_Section) {
        cell.userInteractionEnabled = YES;
        // adding chats number
        UIImageView* chatsNumberView = [[UIImageView alloc] initWithFrame:CGRectMake(SIDE_MENU_WIDTH * 4 / 5, imageYPosition - 15, 30, 30)];
        chatsNumberView.backgroundColor = BounceRed;
        chatsNumberView.layer.cornerRadius = chatsNumberView.frame.size.height / 2;
        chatsNumberView.clipsToBounds = YES;
        chatsNumberView.layer.borderWidth = 3.0f;
        chatsNumberView.layer.borderColor = BounceRed.CGColor;
        // number of messages for the group
        UILabel* numOfMessagesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 30, 20)];
        numOfMessagesLabel.textAlignment = NSTextAlignmentCenter;
        numOfMessagesLabel.text = [NSString stringWithFormat:@"%li", (long)activeChatNumber];
        [numOfMessagesLabel setTextColor:[UIColor whiteColor]];
        [numOfMessagesLabel setBackgroundColor:[UIColor clearColor]];
        [numOfMessagesLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
        [chatsNumberView addSubview:numOfMessagesLabel];
        [cell addSubview:chatsNumberView];
        
        // adding chats number
        UIImageView* redCircleView = [[UIImageView alloc] initWithFrame:CGRectMake(20 , imageYPosition - 5, 10, 10)];
        redCircleView.backgroundColor = BounceRed;
        redCircleView.layer.cornerRadius = redCircleView.frame.size.height / 2;
        redCircleView.clipsToBounds = YES;
        redCircleView.layer.borderWidth = 3.0f;
        redCircleView.layer.borderColor = BounceRed.CGColor;
        [cell addSubview:redCircleView];
        
        UILabel* usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40 , imageYPosition - 20, 100, 40)];
        usernameLabel.font = [UIFont fontWithName:@"FS Albert" size:32];
        usernameLabel.textColor = [UIColor whiteColor];
        usernameLabel.text = @"Chats";
        [cell addSubview:usernameLabel];
        [cell setBackgroundColor:[UIColor darkGrayColor]];
    }
    if (Home_section) {
        cell.userInteractionEnabled = NO;
    }
    if (indexPath.row == Settings_Section) {
        cell.userInteractionEnabled = YES;
        UILabel *settingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, imageYPosition - 20, 100, 40)];
        settingsLabel.font = [UIFont fontWithName:@"FS Albert" size:32];
        settingsLabel.textColor = [UIColor whiteColor];
        settingsLabel.text = @"Settings";
        [cell addSubview:settingsLabel];
        [cell setBackgroundColor:[UIColor darkGrayColor]];
    }
     if (indexPath.row == Terms_Section) {
        cell.userInteractionEnabled = YES;
        UILabel *terms = [[UILabel alloc] initWithFrame:CGRectMake(40, imageYPosition - 20, 100, 40)];
        terms.font = [UIFont fontWithName:@"FS Albert" size:32];
        terms.textColor = [UIColor whiteColor];
        terms.text = @"Terms of Use";
        [cell addSubview:terms];
        [cell setBackgroundColor:[UIColor darkGrayColor]];

    }
     if (indexPath.row == Privacy_Section) {
        cell.userInteractionEnabled = YES;
        UILabel *privacy = [[UILabel alloc] initWithFrame:CGRectMake(40, imageYPosition - 20, 100, 40)];
        privacy.font = [UIFont fontWithName:@"FS Albert" size:32];
        privacy.textColor = [UIColor whiteColor];
        privacy.text = @"Privacy Policy";
        [cell addSubview:privacy];
        [cell setBackgroundColor:[UIColor darkGrayColor]];

    }
    

    return cell;
}

#pragma mark - TableView Delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == Home_section) {
        return nil;
    }
    return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UINavigationController *nvc;
    UIViewController *rootVC;
    
    switch (indexPath.row) {
            
        case Home_section: {
            if (!homeNavigationViewController) {
                rootVC = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
                homeNavigationViewController = [[UINavigationController alloc] initWithRootViewController:rootVC];
            }
            [self openContentNavigationController:homeNavigationViewController];
        }
            break;
            
        case Chats_Section: {
            rootVC = [[RequestsViewController alloc] initWithNibName:@"RequestsViewController" bundle:nil];
            nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
            NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
            [viewControllers addObject:rootVC];
            
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
            if ([self.mainVC isKindOfClass:[SlideMenuViewController class]]) {
                if ([(SlideMenuViewController *)self.mainVC initialIndex] == 1 && [(SlideMenuViewController *)self.mainVC requestId]) {
                     CustomChatViewController *chatView = [[Utility getInstance] createChatViewWithRequestId:[(SlideMenuViewController *)self.mainVC requestId]];
                     [viewControllers addObject:chatView];
                     [nvc setViewControllers:[NSArray arrayWithArray:viewControllers]];
                }
                [(SlideMenuViewController *)self.mainVC setInitialIndex:0] ;
            }
            
            [self openContentNavigationController:nvc];
        }
            break;
        
        case Settings_Section: {
            rootVC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
            nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
            NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
            [viewControllers addObject:rootVC];
            
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
            
            if ([self.mainVC isKindOfClass:[SlideMenuViewController class]]) {

                
                //if ([(SlideMenuViewController *)self.mainVC initialIndex] == 1 && [(SlideMenuViewController *)self.mainVC requestId]) {

                    
                    SettingsViewController *settingsView = [[SettingsViewController alloc] init];
                
                    [viewControllers addObject:settingsView];
                    [nvc setViewControllers:[NSArray arrayWithArray:viewControllers]];
                
                [(SlideMenuViewController *)self.mainVC setInitialIndex:0];
                [self openContentNavigationController:nvc];
                
                //}
            }
        }
            break;
            
        case Terms_Section: {
            rootVC = [[Terms_of_Use_ViewController alloc] initWithNibName:@"Terms_of_Use_ViewController" bundle:nil];
            nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
            NSMutableArray *viewControllers = [[NSMutableArray alloc]init];
            [viewControllers addObject:rootVC];
            
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
            
            if ([self.mainVC isKindOfClass:[SlideMenuViewController class]]) {
                
                Terms_of_Use_ViewController *termsView = [[Terms_of_Use_ViewController alloc] init];
                
                [viewControllers addObject:termsView];
                [nvc setViewControllers:[NSArray arrayWithArray:viewControllers]];
                [(SlideMenuViewController *)self.mainVC setInitialIndex:0];
                [self openContentNavigationController:nvc];
            }
        }
            break;
        
        case Privacy_Section: {
            rootVC = [[Privacy_Policy_ViewController alloc] initWithNibName:@"Privacy_Policy_ViewController" bundle:nil];
            nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
            NSMutableArray *viewControllers = [[NSMutableArray alloc]init];
            [viewControllers addObject:rootVC];
            
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
            
            if ([self.mainVC isKindOfClass:[SlideMenuViewController class]]) {
                
                Privacy_Policy_ViewController *privacyView = [[Privacy_Policy_ViewController alloc] init];
                
                [viewControllers addObject:privacyView];
                [nvc setViewControllers:[NSArray arrayWithArray:viewControllers]];
                [(SlideMenuViewController *)self.mainVC setInitialIndex:0];
                [self openContentNavigationController:nvc];
            }
        }
            break;
            
        default:
            break;
    }

}


#pragma mark -
- (void) setUserNameAndLocationAtCell{
    @try {
        // adding user name
        PFUser* currentUser = [PFUser currentUser];
        self.usernameLabel.text = [currentUser username];
//        self.userCityLabel.text = @"New York City";
        //TODO: Get the actual address of the user by his latitude and longitude
//        PFGeoPoint *userGeoPoint = currentUser[@"CurrentLocation"];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark - St profile Image
- (void) setProfileImage
{
//    PFFile *imageFile = [[PFUser currentUser] objectForKey:PF_USER_THUMBNAIL];
    PFFile *imageFile = [[PFUser currentUser] objectForKey:PF_USER_PICTURE];
    
    MAKE_A_WEAKSELF;
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            profileImage = [UIImage imageWithData:data];
            weakSelf.userProfileImageView.image = profileImage;
        }
    }];

}
- (IBAction)signoutButtonClicked:(id)sender {
    NSLog(@"sign out pressed!");
    [PFUser logOut];
    // stop the request manager update
    [[RequestManger getInstance] invalidateCurrentRequest];
    UINavigationController *nvc;
    UIViewController *rootVC;
    rootVC = [[Tutorial alloc] init];
    
    Tutorial *introPagesViewController = [[Tutorial alloc] init];
    nvc = [[UINavigationController alloc] initWithRootViewController:introPagesViewController];
    [self openContentNavigationController:nvc];
}

- (IBAction)changeImageButtonClicked:(id)sender {
    
    if (profileImage != nil && ![self isProfileDefaultImage]) {
        imageActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Remove Photo", @"Upload photo", @"Take photo", nil];
    } else {
        if (!imageActionSheet) {
            imageActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"Upload photo", @"Take photo", nil];

        }
            }
    
    [imageActionSheet showInView:self.view];

}
- (void)setDefaultImage {
//    self.profileImageView.image = [UIImage imageNamed:PROFILE_DEFAULT_IMAGE_PATH];
//    self.profileImageView.contentMode = UIViewContentModeCenter;
//    self.profileImage = nil;
}
-(BOOL) isProfileDefaultImage{
//    return [self image:self.profileImage isEqualTo:[UIImage imageNamed:PROFILE_DEFAULT_IMAGE_PATH]];
    return NO;
}
#pragma mark - Change image
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (profileImage != nil && ![self isProfileDefaultImage]) {
//        if (buttonIndex == 0) { // remove photo
//            profileImage = nil;
//            [self setDefaultImage];
//            [self saveProfileImageOnCloud];
//        } else if (buttonIndex == 1) { //upload photo
//            [self showPhotoPicker];
//        } else if (buttonIndex == 2) { //take photo
//            [self showCameraPicker];
//        }
//        else if (buttonIndex == actionSheet.cancelButtonIndex) {
//            if (!profileImage) {
//                [self setDefaultImage];
//            }
//        }
//    } else {
//        if (buttonIndex == 0) { //upload photo
//            [self showPhotoPicker];
//        } else if (buttonIndex == 1) { //take photo
//            [self showCameraPicker];
//        }
//        else if (buttonIndex == actionSheet.cancelButtonIndex) {
//            [self setDefaultImage];
//        }
//    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation
{
    if (profileImage != nil && ![self isProfileDefaultImage]) {
        if (buttonIndex == 0) { // remove photo
            profileImage = nil;
            [self setDefaultImage];
            [self saveProfileImageOnCloud];
        } else if (buttonIndex == 1) { //upload photo
            [self showPhotoPicker];
        } else if (buttonIndex == 2) { //take photo
            [self showCameraPicker];
        }
        else if (buttonIndex == actionSheet.cancelButtonIndex) {
            if (!profileImage) {
                [self setDefaultImage];
            }
        }
    } else {
        if (buttonIndex == 0) { //upload photo
            [self showPhotoPicker];
        } else if (buttonIndex == 1) { //take photo
            [self showCameraPicker];
        }
        else if (buttonIndex == actionSheet.cancelButtonIndex) {
            [self setDefaultImage];
        }
    }
}

#pragma mark - Camera piker
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
#pragma mark - Image picker delegate
#pragma mark - ImagePicker Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
    //set default image
    if (!profileImage) {
        [self setDefaultImage];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (image) {
        profileImage = image;
        self.userProfileImageView.image = image;
        self.userProfileImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self saveProfileImageOnCloud];
        } else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error!!" message:@"Error in uploading image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - SaveImage
-(void) saveProfileImageOnCloud{
    dispatch_queue_t firstQueue = dispatch_queue_create("usersList", 0);
    NSData* data;
    PFFile *imageFile;
    PFUser *currentUser = [PFUser currentUser];
    if (!profileImage) {
        [[Utility getInstance] showProgressHudWithMessage:@"Remove image .." withView:self.view];
        [[PFUser currentUser] removeObjectForKey:PF_USER_THUMBNAIL];
        self.userProfileImageView.image = nil;

        [[PFUser currentUser] saveInBackground];
        [[Utility getInstance] hideProgressHud];
        
    }
    else{
        [[Utility getInstance] showProgressHudWithMessage:@"Uploading Image" withView:self.view];
//        if (profileImage.size.width > 100) profileImage = SquareImage(profileImage, 100);
        data = UIImageJPEGRepresentation(profileImage, 1.0);
        imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@%@", [[PFUser currentUser] username], @".jpg"] data:data];
        
        MAKE_A_WEAKSELF;
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                if (succeeded) {
                    currentUser[PF_USER_THUMBNAIL] = imageFile;
                    // update the profile image view
                    weakSelf.userProfileImageView.image = profileImage;
                    [currentUser saveInBackground];
                }
            } else {
                // Handle error
                
                NSLog(@"FIX DIS BLOCK ERROR");
            }
        } progressBlock:^(int percentDone) {
            if (percentDone >= 100) {
                [[Utility getInstance] hideProgressHud];
            }
        }
         ];
        
    }
    dispatch_async(firstQueue, ^{
    });
}

- (void)setImageFromPath:(NSString*)imagePath toView:(UIImageView*)imageView cropImage:(BOOL)cropImage {
    if (IS_IOS8) {
        PHFetchResult* result = [PHAsset fetchAssetsWithALAssetURLs:[NSArray arrayWithObject:[NSURL URLWithString:imagePath]] options:nil];
        NSLog(@"result = %@", result);
        
        PHAsset* asset = result.firstObject;
        NSLog(@"asset = %@", asset);
        
        float retinaMultiplier = 1; //[UIScreen mainScreen].scale;
        CGSize retinaSquare = CGSizeMake(imageView.bounds.size.width * retinaMultiplier, imageView.bounds.size.height * retinaMultiplier);
        
        __block UIImage *returnImage;
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        //        options.normalizedCropRect = CGRectMake(0, 0, retinaSquare.height, retinaSquare.width);
        options.version = PHImageRequestOptionsVersionOriginal;
        options.deliveryMode =  PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        options.synchronous = NO;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:CGSizeMake(retinaSquare.width, retinaSquare.height)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:options
                                                resultHandler:
         ^(UIImage *result, NSDictionary *info) {
             returnImage = result;
             //             NSLog(@"size = %f %f", returnImage.size.width, returnImage.size.height);
             imageView.image = returnImage;
         }];
    } else {
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            CGImageRef iref = [rep fullScreenImage];
            if (iref) {
                UIImage *image = [UIImage imageWithCGImage:iref scale:3 orientation:0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = image;
                });
                iref = nil;
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror)
        {
            NSLog(@"Can't get image - %@",[myerror localizedDescription]);
        };
        
        NSURL *asseturl = [NSURL URLWithString:imagePath];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:asseturl
                           resultBlock:resultblock
                          failureBlock:failureblock];
        });
    }
}

#pragma mark - update chat numer
- (void) updateChatNumber:(NSNotification *) notification
{
    activeChatNumber = [[notification.userInfo objectForKey:@"Chat"] integerValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:Chats_Section inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

@end
