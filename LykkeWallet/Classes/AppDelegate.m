//
//  AppDelegate.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 08.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "ABPadLockScreen.h"
#import "TKButton.h"
#import "LWConstants.h"
#import "UIColor+Generic.h"
#import "UIView+Toast.h"
#import "LWKeychainManager.h"
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
#import "LWPushNotificationView.h"
#import "LWPrivateKeyManager.h"



@interface AppDelegate () {
    NSData *notificationToken;
}


#pragma mark - Private

- (void)customizePINScreen;
- (void)customizeNavigationBar;
- (void)customizeLabel;
- (void)customizeButton;
- (void)customizeTextField;
- (void)customizePageControl;
- (void)customizeSwitcher;
- (void)customizeTabBar;

@end


@implementation AppDelegate


#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // init fabric
    
//    NSString *userAgent=[NSString stringWithFormat:@"DeviceType=iPhone;AppVersion=%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
//    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil];
//    
//    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
//    
//    
//    NSData *data=[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://user-agent.me"]] returningResponse:nil error:nil];
//    
//    NSString *string=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", string);
    
//    NSString *sss=[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    //Clear keychain on first run in case of reinstallation
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        // Delete values from keychain here
        
        [[LWKeychainManager instance] clear];
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [Fabric with:@[[Crashlytics class]]];

    [self customizePINScreen];
    [self customizeNavigationBar];
    [self customizeLabel];
    [self customizeButton];
    [self customizeTextField];
    [self customizePageControl];
    [self customizeSwitcher];
    [self customizeTabBar];
    
    [CSToastManager setQueueEnabled:NO];

    // init main controller
    self.mainController = [LWAuthNavigationController new];
    
    // init window
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.mainController;
    [self.window makeKeyAndVisible];
    
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
//     Register for remote notifications.
    [[UIApplication sharedApplication] registerForRemoteNotifications];

    NSDictionary *apnsBody = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (apnsBody) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [LWPushNotificationView showPushNotification:apnsBody clickImmediately:YES];
        });
    }
    
//    [LWPrivateKeyManager shared];   //Testing
//    [LWPushNotificationView showPushNotification:@{@"aps":@{@"alert":@"Test alert", @"type":@(1)}} clickImmediately:NO];//Testing
    
//    NSString *sss=[LWKeychainManager instance].privateKeyLykke;//Testing
    NSLog(@" ");
//    [[LWKeychainManager instance] clearLykkePrivateKey];
    
    return YES;
}

// Handle remote notification registration.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken {
    
//    NSData *data=deviceToken;
//    NSUInteger capacity = data.length * 2;
//    NSMutableString *sbuf = [NSMutableString stringWithCapacity:capacity];
//    const unsigned char *buf = data.bytes;
//    NSInteger i;
//    for (i=0; i<data.length; ++i) {
//        [sbuf appendFormat:@"%02X", (NSUInteger)buf[i]];
//    }
//    
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Token" message:sbuf delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alert show];

    notificationToken=deviceToken;
    
    if([LWKeychainManager instance].notificationsTag)
        [self registerForNotificationsInAzureWithTag:[LWKeychainManager instance].notificationsTag];
 }

-(void) registerForNotificationsInAzureWithTag:(NSString *) tag
{
    NSString *HUBLISTENACCESS;//=@"Endpoint=sb://lykke-dev.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=KLvwXsxLPxY2dCgXChIp/QD5/Kg00+tgruhFom59098=";
    NSString *HUBNAME;//=@"lykke-notifications-dev";
    
    if([[LWKeychainManager instance].address isEqualToString:kProductionServer] || [[LWKeychainManager instance].address isEqualToString:kStagingTestServer])
    {
        HUBLISTENACCESS=@"Endpoint=sb://lykkewallet.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=XwEA5pk9uDLkZXgnZF5sdDrZYEx5eoaE7LFlLoy+wh4=";
        HUBNAME=@"lykke-notifications";
    }
    else
    {
        HUBLISTENACCESS=@"Endpoint=sb://lykke-dev.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=KLvwXsxLPxY2dCgXChIp/QD5/Kg00+tgruhFom59098=";
        HUBNAME=@"lykke-notifications-dev";

    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:HUBLISTENACCESS
                                                             notificationHubPath:HUBNAME];
    
    [hub registerNativeWithDeviceToken:notificationToken tags:[NSSet setWithObject:tag] completion:^(NSError* error) {
        if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Error registering for notifications" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];

        }
        else {
            NSLog(@"Registered for notifications");
        }
    }];
});
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification: (NSDictionary *)userInfo {
    NSLog(@"%@", userInfo);
    
//    public enum NotificationType
//    {
//        KycSucceess = 0,
//        KycRestrictedArea = 1,
//        KycNeedToFillDocuments = 2,
//        
//        TransctionFailed = 3,
//        TransactionConfirmed = 4
//    }
    
    UIApplicationState state = [application applicationState];
    // user tapped notification while app was in background
    if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
        [LWPushNotificationView showPushNotification:userInfo clickImmediately:YES];
    } else {
        [LWPushNotificationView showPushNotification:userInfo clickImmediately:NO];
    }
    
    
    
    
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Notification" message:[[userInfo objectForKey:@"aps"] valueForKey:@"alert"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alert show];

}


- (void)application:(UIApplication *)app
didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Error getting notifications token" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Private

- (void)customizePINScreen {
    [[ABPadLockScreenView appearance] setViewColor:[UIColor whiteColor]];
    [[ABPadLockScreenView appearance] setLabelColor:[UIColor blackColor]];
    [[ABPadButton appearance] setBackgroundColor:[UIColor clearColor]];
    [[ABPadButton appearance] setBorderColor:[UIColor colorWithHexString:kABPadBorderColor]];
    [[ABPadButton appearance] setSelectedColor:[UIColor lightGrayColor]];
    [[ABPadButton appearance] setTextColor:[UIColor blackColor]];
    [[ABPinSelectionView appearance] setSelectedColor:[UIColor colorWithHexString:kABPadSelectedColor]];
}

- (void)customizeNavigationBar {
    UIFont *font = [UIFont fontWithName:kNavigationBarFontName size:kNavigationBarFontSize];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor colorWithHexString:kNavigationBarFontColor], NSForegroundColorAttributeName,
                                font, NSFontAttributeName,
                                nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:kNavigationTintColor]];
    
    [[UINavigationBar appearance] setTintColor:
     [UIColor colorWithHexString:kNavigationBarTintColor]];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                       forBarMetrics:UIBarMetricsDefault];
    
    

    
    
    
}

- (void)customizeLabel {
#ifdef PROJECT_IATA
#else
    [[UILabel appearance] setTextColor: [UIColor colorWithHexString:kLabelFontColor]];
#endif
}

- (void)customizeButton {
    [[TKButton appearance] setTitleColor:[UIColor colorWithHexString:kDisabledButtonFontColor]
                                forState:UIControlStateDisabled];
    
    [[TKButton appearance] setTitleColor:[UIColor colorWithHexString:kEnabledButtonFontColor]
                                forState:UIControlStateNormal];
    
    [[TKButton appearance] setTitleFont:[UIFont fontWithName:kButtonFontName
                                                        size:kButtonFontSize]];
}

- (void)customizeTextField {
    [[UITextField appearance] setFont:[UIFont fontWithName:kTextFieldFontName
                                                      size:kTextFieldFontSize]];
    [[UILabel appearanceWhenContainedIn:[UITextField class], nil] setTextColor:[UIColor colorWithHexString:kTextFieldFontColor]];
}

- (void)customizePageControl {
    [[UIPageControl appearance] setPageIndicatorTintColor:[UIColor colorWithHexString:kPageControlDotColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor:[UIColor colorWithHexString:kPageControlActiveDotColor]];
}

- (void)customizeSwitcher {
    [[UISwitch appearance] setOnTintColor:[UIColor colorWithHexString:kMainElementsColor]];
    [[UISwitch appearance] setTintColor:[UIColor colorWithHexString:kMainElementsColor]];
}

- (void)customizeTabBar {
//    [[UITabBarItem appearance] setTitleTextAttributes: @{ NSForegroundColorAttributeName : [UIColor colorWithHexString:kTabBarTintColor] } forState:UIControlStateNormal];
//    [[UITabBarItem appearance] setTitleTextAttributes: @{ NSForegroundColorAttributeName : [UIColor colorWithHexString:kTabBarSelectedTintColor] } forState:UIControlStateSelected];
    
//    [[UITabBar appearance] setTintColor:[UIColor colorWithHexString:kTabBarSelectedTintColor]];
    
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHexString:kTabBarBackgroundColor]];
    
    
    
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]];

    

    
    [[UITabBarItem appearance] setTitleTextAttributes: @{ NSForegroundColorAttributeName : [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Regular" size:8], NSKernAttributeName:@(3) } forState:UIControlStateSelected];
    [[UITabBarItem appearance] setTitleTextAttributes: @{ NSForegroundColorAttributeName : [UIColor colorWithRed:156.0/255 green:163.0/255 blue:172.0/255 alpha:1], NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Regular" size:8], NSKernAttributeName:@(3)  } forState:UIControlStateNormal];

    [[UITabBar appearance] setBarTintColor:[UIColor colorWithWhite:249.0/255 alpha:1]];
    
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    

}

@end
