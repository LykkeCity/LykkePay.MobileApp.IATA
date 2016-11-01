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
#import "LWTransactionManager.h"
#import "LWURLProtocol.h"
#import "LWUtils.h"
#import "LWAuthManager.h"

#import "LWMyLykkeSuccessViewController.h"

#import "LWBackupNotificationView.h"

@import PushKit;



@interface AppDelegate () <PKPushRegistryDelegate>{
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
    
    
    
    BOOL success=[NSURLProtocol registerClass:[LWURLProtocol class]];
    
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];


    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"] || [[[NSUserDefaults standardUserDefaults] stringForKey:@"LWLastLaunchedVersion"] isEqualToString:build]==NO) {
        // Delete values from keychain here
        
        [[LWKeychainManager instance] clear];
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        [[NSUserDefaults standardUserDefaults] setObject:build forKey:@"LWLastLaunchedVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
//    [Fabric with:@[[Crashlytics class]]];
    [Fabric with:@[CrashlyticsKit]];

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
    
//    [LWTransactionManager signTransactionRaw:@"01000000049c2cbf06bfee25c9041b7ccf474614e4de26f18abbd4cf0312c71ff99742f7570100000000ffffffff86701d6556c28f3ab528e11cad65439ff5980691f4e44ecc8023739bb42a559edb0100006a47304402206a4c389d6fd4faeec2dfa94853883b276d9b3f2cae646ad850802759fa6f78f3022006bd15223d4598ae084eac1a1c83587f326dd445a6582062fa26510d74833c40012103f50cb40deb9026745f2fcfe2a07457771732d0786f406575d6246d462109a908ffffffff86701d6556c28f3ab528e11cad65439ff5980691f4e44ecc8023739bb42a559e960200006b48304502210097cec5e508d4179c2ec696c705a7c8f687fca97eb13b76fc0d3f491732dd073502205d3c399cfd192c278e424bf1059f3551ae1ad2cbbe57f401801e266d0de77aff012103f50cb40deb9026745f2fcfe2a07457771732d0786f406575d6246d462109a908ffffffff86701d6556c28f3ab528e11cad65439ff5980691f4e44ecc8023739bb42a559e840300006a473044022023ed467a7156fc7ff34e4ae4d6c44d29b6496b3cdc317813441fa0b042f631c3022050fac0e5bb24ca20bdd2fd78304897d5e4237d90b701dbf93fae1e387c9da7fc012103f50cb40deb9026745f2fcfe2a07457771732d0786f406575d6246d462109a908ffffffff030000000000000000126a104f41010002c0a3a8b55a8094ebdc0300aa0a0000000000001976a91493c118725804e10e46f054b1d5d5b44b0657c00a88acaa0a0000000000001976a91493fac6c4129a999a045c62c49bb2000a32d4dd2788ac00000000" forModel:nil];   //Testing
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    [LWPushNotificationView showPushNotification:@{@"aps":@{@"alert":@"Need to show sticker above action bar", @"type":@(3)}} clickImmediately:NO];//Testing
//    });

    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        LWMyLykkeSuccessViewController *presenter=[[LWMyLykkeSuccessViewController alloc] init];//Testing
//        [presenter showInWindow:[UIApplication sharedApplication].keyWindow];
//    });

//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            LWBackupNotificationView *view = [[[NSBundle mainBundle] loadNibNamed:@"LWBackupNotificationView" owner:self options:nil] objectAtIndex:0];
//            [view show];
//        });

    //LWMyLykkeSuccessViewController
    
//    NSString *sss=[LWKeychainManager instance].privateKeyLykke;//Testing
//    NSLog(@" ");
//    [[LWKeychainManager instance] clearLykkePrivateKey];
    
//    [LWPrivateKeyManager encodedPrivateKeyWif:@"123456Abcdefghijklmnopq" withPassPhrase:@"The game"];//Testing
    
//    [LWPrivateKeyManager generateSeedWords]; //Testing
    
//    [[LWPrivateKeyManager shared] signatureForMessageWithLykkeKey:@"Test message"]; //Testing
    
//    NSArray *fontFamilies = [UIFont familyNames];
//    for (int i = 0; i < [fontFamilies count]; i++)
//    {
//        NSString *fontFamily = [fontFamilies objectAtIndex:i];
//        NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
//        NSLog (@"%@: %@", fontFamily, fontNames);
//    }
//    
    
    
//    NSString *sss=[LWPrivateKeyManager hashForString:@"123456"];  //Testing
    
    [[LWAuthManager instance] requestAllAssetPairs];
    [[LWAuthManager instance] requestAPIVersion];
    [[LWAuthManager instance] requestSwiftCredentials];
    
    
    
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    
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
            if(([[LWKeychainManager instance].address isEqualToString:kProductionServer] || [[LWKeychainManager instance].address isEqualToString:kStagingTestServer])==NO)
            {
//                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Error registering for notifications" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
            }

        }
        else {
            NSLog(@"Registered for notifications");
        }
    }];
});
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification: (NSDictionary *)userInfo {
    NSLog(@"%@", userInfo);
    
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:nil];
//    
//    NSString *mmm=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Notification" message:mmm delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alert show];
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
    
    UIApplication *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
 //       [app endBackgroundTask:bgTask];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(70 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [app endBackgroundTask:bgTask];
    });

}


-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
        NSURL *url=[NSURL URLWithString:[@"https://snetkov.me/lykke/push/test/testlog.php?a=" stringByAppendingString:userInfo[@"data-id"]]];
        [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:nil error:nil];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            completionHandler(UIBackgroundFetchResultNewData);

        });
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//            
//            [[NSUserDefaults standardUserDefaults] setObject:@"Got notification" forKey:@"TestPushBack"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            completionHandler(UIBackgroundFetchResultNewData);
//        });
    
    });


}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationDidBecomeActiveNotification" object:nil];
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






- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type{
    if([credentials.token length] == 0) {
        NSLog(@"voip token NULL");
        return;
    }
    
    NSLog(@"PushCredentials: %@", credentials.token);
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
    NSLog(@"didReceiveIncomingPushWithPayload");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSURL *url=[NSURL URLWithString:[@"https://snetkov.me/lykke/push/test/testlog.php?a=" stringByAppendingString:payload.dictionaryPayload[@"data-id"]]];
        [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:nil error:nil];
        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            
//            completionHandler(UIBackgroundFetchResultNewData);
//            
        });

}





@end
