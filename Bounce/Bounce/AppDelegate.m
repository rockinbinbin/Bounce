//
//  AppDelegate.m
//  hobble.1.1
//
//  Created by Robin Mehta on 8/7/14.
//  Copyright (c) 2014 hobble. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "ParseManager.h"
#import "RequestsViewController.h"
#import "CustomChatViewController.h"
#import "Utility.h"
#import "bounce-Swift.h"

@implementation AppDelegate {
    NSString *notificationRequestId;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialize Parse
    [Parse setApplicationId:PARSE_APP_ID clientKey:PARSE_CLIENT_KEY];
    [PFAnalytics trackAppOpenedWithLaunchOptionsInBackground:launchOptions block:nil];

    // Initialize PFFacebookUtils
    [PFFacebookUtils initializeFacebook];

    // Configure status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [self registerRemoteNotification:application];
    [self setSegmentControlAppearance];
    [self setTableViewAppearance];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // If user is logged in already
    if ([PFUser currentUser] != nil && [[PFUser currentUser] valueForKey:@"setupComplete"]) {
        [[PFUser currentUser] fetchInBackgroundWithBlock:nil];

        // If logged in user completed setup
        if ([[PFUser currentUser] valueForKey:@"setupComplete"]) {

            NSString *requestId = [launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:OBJECT_ID];

            // If logged in setup complete user has a request, open it
            if (requestId) {
                [self openRequestViewController:requestId];
            } else {
                self.window.rootViewController = [RootTabBarController rootTabBarControllerWithNavigationController];
            }

        // If logged in user did not complete setup
        } else {
            self.window.rootViewController = [[StudentStatusViewController alloc] init];
        }

    // If setup needs to be started
    } else {
        self.window.rootViewController = [[IntroViewController alloc] init];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Application's Documents directory

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ( application.applicationState == UIApplicationStateActive ){
        // app was already in the foreground
//        [PFPush handlePush:userInfo];
        if ([[userInfo objectForKey:@"aps"] objectForKey:NOTIFICATION_ALERT_MESSAGE]) {
            NSString *message = [[userInfo objectForKey:@"aps"] objectForKey:NOTIFICATION_ALERT_MESSAGE];
            notificationRequestId = [userInfo objectForKey:OBJECT_ID];
            if ([self isRequestChatViewOpened]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
                                                                message: message
                                                               delegate: self
                                                      cancelButtonTitle: @"OK"
                                                      otherButtonTitles: nil];
                [alert show];
            }
        }
    } else {
        [self appOpenedFromNotification:userInfo];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

#pragma mark - Segment Control Appearance
- (void) setSegmentControlAppearance
{
    @try {
        [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
        [[UISegmentedControl appearance] setBackgroundColor:[UIColor whiteColor]];
        [[UISegmentedControl appearance] setTintColor:BounceRed];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}
- (void) setTableViewAppearance
{
    @try {
        // remove empty cells
        [[UITableView appearance] setTableFooterView: [[UIView alloc] initWithFrame:CGRectZero]];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@", exception);
    }
}

#pragma mark 
- (void) registerRemoteNotification:(UIApplication *) application
{
    // register for remote notifications
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS 8
        UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
}

- (void) appOpenedFromNotification:(NSDictionary *)userInfo{
    @try {
        NSString *requestId = [userInfo objectForKey:OBJECT_ID];
        if (requestId && [[ParseManager getInstance] isThereLoggedUser]) {
            [self openRequestViewController:requestId];
        }
    }
    @catch (NSException *exception) {
        
    }
}

-(void)openRequestViewController:(NSString *) requestId
{
    UIViewController *rootVC = [RequestsViewController new];
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    [viewControllers addObject:rootVC];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    BOOL requestValid = [self isValidRequest:requestId];
    
    // if the app in back ground
    if (requestValid) {
        // open chat view
        CustomChatViewController *chatView = [[Utility getInstance] createChatViewWithRequestId:requestId];
        [viewControllers addObject:chatView];
        [nvc setViewControllers:[NSArray arrayWithArray:viewControllers]];
    }
}

#pragma mark get request
- (BOOL) isValidRequest:(NSString *) requestId
{
    PFObject *request = [[ParseManager getInstance] retrieveRequestUpdate:requestId];
    if ([[ParseManager getInstance] isValidRequestReceiver:request]) {
        if ([[Utility getInstance] isRequestValid:[request createdAt] andTimeAllocated:[[request objectForKey:PF_REQUEST_TIME_ALLOCATED] integerValue]] && ![[request objectForKey:PF_REQUEST_IS_ENDED] boolValue] ){
        NSLog(@"valid");
        return YES;
        }
        return  NO;
    }
    else
        return NO;
}

#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (notificationRequestId && [[ParseManager getInstance] isThereLoggedUser]) {
        // current active chat thread not equal to the notification chat thread
        [self openRequestViewController:notificationRequestId];
    }
}
#pragma mark - Request Chat View
- (BOOL) isRequestChatViewOpened
{
    if (!self.window.rootViewController) {
        return false;
    }
    
    BOOL activeControllerIsChatView = [self.window.rootViewController isKindOfClass:[CustomChatViewController class]];
    
    return (!activeControllerIsChatView || (activeControllerIsChatView && ![[(CustomChatViewController*)self.window.rootViewController groupId] isEqualToString:notificationRequestId]));
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.bouncelabs.test" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"test.sqlite"];
    
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
