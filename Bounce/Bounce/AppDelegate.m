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
#import "IntroPagesViewController.h"
#import "SlideMenuViewController.h"
#import "ParseManager.h"
#import "RequestsViewController.h"
#import "CustomChatViewController.h"

@implementation AppDelegate
{
    SlideMenuViewController* mainViewController;
    NSString *notificationRequestId;
}
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // set parse keys
    [Parse setApplicationId:PARSE_APP_ID clientKey:PARSE_CLIENT_KEY];
    [PFFacebookUtils initializeFacebook];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self registerRemoteNotification:application];
    // Set the appearane of the application segment controls
    [self setSegmentControlAppearance];
    [self setTableViewAppearance];
    UINavigationController *navigationController;
    
    // if user looged in skip the introduction screens and move to home screen
    if ([[ParseManager getInstance] isThereLoggedUser]) {
        NSString *requestId = [launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:OBJECT_ID];
        if (requestId) {
            [self openRequestViewController:requestId];
        }else{
            mainViewController = [[SlideMenuViewController alloc] init];
        }
        navigationController  = [[UINavigationController alloc] initWithRootViewController:mainViewController];

    }else{
        IntroPagesViewController* introPagesViewController = [[IntroPagesViewController alloc] initWithNibName:@"IntroPagesViewController" bundle:nil];
        navigationController  = [[UINavigationController alloc] initWithRootViewController:introPagesViewController];
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navigationController;
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

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"hobble_1_1" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"hobble_1_1.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

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
            if (mainViewController) {
                if ([self isRequestChatViewOpened]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
                                                                    message: message
                                                                   delegate: self
                                                          cancelButtonTitle: @"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                }
            }
        }
    }else{
        [self appOpendFromNotification:userInfo];
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
        [[UISegmentedControl appearance] setTintColor:DEFAULT_COLOR];
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
    } else {
        // iOS 7 or iOS 6
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }

}

- (void) appOpendFromNotification:(NSDictionary *)userInfo{
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
    UIViewController *rootVC = [[RequestsViewController alloc] initWithNibName:@"RequestsViewController" bundle:nil];
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    [viewControllers addObject:rootVC];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    BOOL requestValid = [self isValidRequest:requestId];
    
    if (mainViewController) {
        // if the app in back ground
        if (requestValid) {
            // open chat view
            CustomChatViewController *chatView = [[Utility getInstance] createChatViewWithRequestId:requestId];
            [viewControllers addObject:chatView];
            [nvc setViewControllers:[NSArray arrayWithArray:viewControllers]];
        }
        [mainViewController.leftMenu openContentNavigationController:nvc];
    }else{
        // if the app launched
        // make app open in chat view not home
        mainViewController = [[SlideMenuViewController alloc] init];
        mainViewController.initialIndex = 1;
        if (requestValid) {
            mainViewController.requestId = requestId;
        }else{
            mainViewController.requestId = nil;
        }
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
    UIViewController *activeViewController = [[mainViewController currentActiveNVC] topViewController];
    BOOL activeViewControllerIsChatView = [activeViewController isKindOfClass:[CustomChatViewController class]];
    if (!activeViewControllerIsChatView || (activeViewControllerIsChatView && ![[(CustomChatViewController*)activeViewController groupId] isEqualToString:notificationRequestId])) {
        return YES;
    }else{
        return NO;
    }
}
@end
