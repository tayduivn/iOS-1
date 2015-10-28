//
//  AppDelegate.m
//  HouseHunter
//
//  
//  Copyright (c) 2015 MandMBadgers. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <FHSTwitterEngineAccessTokenDelegate>

@end


@implementation AppDelegate

@synthesize contentViewController;
@synthesize sideViewController;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize paperFoldNavController;
@synthesize session;

+(AppDelegate *)instance
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

+(void) foldLeftView {
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [[delegate.paperFoldNavController paperFoldView] setPaperFoldState:PaperFoldStateDefault animated:YES];
}

+(void) unfoldLeftView {
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [[delegate.paperFoldNavController paperFoldView] setPaperFoldState:PaperFoldStateLeftUnfolded animated:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [MGUIAppearance enhanceNavBarAppearance:NAV_BAR_BG];
    
    [MGUIAppearance enhanceBarButtonAppearance:WHITE_TINT_COLOR];
    
    [MGUIAppearance enhanceToolbarAppearance:NAV_BAR_BG];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    if (DOES_SUPPORT_IOS7) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    contentViewController = [storyboard instantiateViewControllerWithIdentifier:@"storyboardNavigation"];
    
    paperFoldNavController = [[PaperFoldNavigationController alloc] initWithRootViewController:contentViewController];
    [self.window setRootViewController:paperFoldNavController];
    
    sideViewController = [storyboard instantiateViewControllerWithIdentifier:@"storyboardSide"];
    
    [paperFoldNavController setLeftViewController:sideViewController
                                            width:SIDE_VIEW_FRAME_WIDTH];
    
    [paperFoldNavController setRightViewController:nil
                                             width:250.0
                                rightViewFoldCount:3
                               rightViewPullFactor:0.9];
    
    paperFoldNavController.paperFoldView.timerStepDuration = 0.025;
    paperFoldNavController.paperFoldView.paperFoldInitialPanDirection = PaperFoldInitialPanDirectionHorizontal;
    
    [paperFoldNavController.paperFoldView setEnableLeftFoldDragging:NO];
    [paperFoldNavController.paperFoldView setEnableTopFoldDragging:NO];
    [paperFoldNavController.paperFoldView setEnableBottomFoldDragging:NO];
    [paperFoldNavController.paperFoldView setEnableRightFoldDragging:NO];
    [paperFoldNavController.paperFoldView setEnableHorizontalEdgeDragging:NO];
    [self.window makeKeyAndVisible];
    
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:TWITTER_CONSUMER_KEY
                                                     andSecret:TWITTER_CONSUMER_SECRET];
    
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    
    [MGFileManager deleteAllFilesAtDocumentsFolderWithExt:@"png"];
    
    NSLog( @"### running FB sdk version: %@", [FBSettings sdkVersion] );
    
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppEvents activateApp];
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"data.sqlite"];
    
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

#pragma mark - TWITTER

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"TWITTER_ACCESS_TOKEN"];
}

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"TWITTER_ACCESS_TOKEN"];
}


#pragma mark - facebook

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:self.session];
}



@end
