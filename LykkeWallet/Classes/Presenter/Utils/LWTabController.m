//
//  LWTabController.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 08.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWTabController.h"
#import "LWAuthManager.h"
#import "LWAuthNavigationController.h"


@interface LWTabController ()<LWAuthManagerDelegate> {
 
    UIView *lineView;
}

@end


@implementation LWTabController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    lineView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 0.5)];
    lineView.backgroundColor=[UIColor colorWithRed:211.0/255 green:214.0/255 blue:219.0/255 alpha:1];
    [self.tabBar addSubview:lineView];
    
    [LWAuthManager instance].delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
    [[LWAuthManager instance] requestAppSettings];
    [[LWAuthManager instance] requestDictionaries];
    [[LWAuthManager instance] requestAllAssets];
    [[LWAuthManager instance] requestBaseAssets];
    [[LWAuthManager instance] requestGetPushSettings];
    [[LWAuthManager instance] requestGetRefundAddress];
    [[LWAuthManager instance] requestAPIVersion];
    [[LWAuthManager instance] requestPrevCardPayment];
    
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidNotAuthorized:(LWAuthManager *)manager {
    [((LWAuthNavigationController *)self.navigationController) logout];
}

@end
