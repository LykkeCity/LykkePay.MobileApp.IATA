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


@interface AppDelegate () {
    
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
    
    
    return YES;
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
    [[UITabBarItem appearance] setTitleTextAttributes: @{ NSForegroundColorAttributeName : [UIColor colorWithHexString:kTabBarTintColor] } forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes: @{ NSForegroundColorAttributeName : [UIColor colorWithHexString:kTabBarSelectedTintColor] } forState:UIControlStateSelected];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithHexString:kTabBarSelectedTintColor]];
    
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHexString:kTabBarBackgroundColor]];
    
    
    
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1]];
    
    [[UITabBarItem appearance] setTitleTextAttributes: @{ NSForegroundColorAttributeName : [UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:1] } forState:UIControlStateSelected];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithWhite:249.0/255 alpha:1]];
    


}

@end
