//
//  AppDelegate.m
//  Kickoff South Bend
//
//  Created by Christian Poellabauer on 3/5/13.
//  Copyright (c) 2013 Christian Poellabauer. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h> 
#import "ProfileData.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Initialize user profile data structure
    userProfileData = [ProfileData sharedInstance];
    [userProfileData setUserName:@""];
    [userProfileData setEmailAddress:@""];
    [userProfileData setContactAddress:@""];
    [userProfileData setPhoneNumber1:@""];
    [userProfileData setPhoneNumber2:@""];
    [userProfileData setProfileActive:0];
    [userProfileData setLocationTracking:false];

    [Parse setApplicationId:@"Ig5J9neTZHgB77Yj5P5XqyPJGz74V2NsLo9VNMAm"
                  clientKey:@"9sL4NqgJ192MI8kilhowJCAv96sTUM9EdlCCJ4sD"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    return YES;
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
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
    
    BOOL locTrackingOn = [userProfileData getLocationTracking];
    
    NSLog(@"App entered background (%d)", locTrackingOn);
    
    if (locTrackingOn) {
        CLLocationManager *thisLocationManager = [userProfileData getLocationMgr];
        [thisLocationManager startMonitoringSignificantLocationChanges];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    BOOL locTrackingOn = [userProfileData getLocationTracking];
    
    NSLog(@"App entered foreground (%d)", locTrackingOn);

    if (locTrackingOn) {
        CLLocationManager *thisLocationManager = [userProfileData getLocationMgr];
        [thisLocationManager stopMonitoringSignificantLocationChanges];
        [thisLocationManager startUpdatingLocation];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
