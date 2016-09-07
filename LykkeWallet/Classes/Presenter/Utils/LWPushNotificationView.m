//
//  LWPushNotificationView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 07/07/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPushNotificationView.h"
#import "LWKYCManager.h"
#import "LWKYCInvalidDocumentsPresenter.h"
#import "LWKYCPendingPresenter.h"
#import "LWAuthComplexPresenter.h"
#import "LWMyLykkeSuccessViewController.h"




@implementation UIWindow (PazLabs)

- (UIViewController *)visibleViewController {
    UIViewController *rootViewController = self.rootViewController;
    return [UIWindow getVisibleViewControllerFrom:rootViewController];
}

+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [UIWindow getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [UIWindow getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [UIWindow getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

@end

@interface LWPushNotificationView() <LWKYCInvalidDocumentsPresenterDelegate>
{
    NSDictionary *pushDict;
    int type;
    UILabel *label;
    UIButton *skipButton;
    
    UIWindow *window;
    
    UIWindow *keyWindow;
}

@end

@implementation LWPushNotificationView

-(id) initWithNotification:(NSDictionary *) _pushDict
{
    self=[super init];
    
    pushDict=_pushDict;
    
    keyWindow=[UIApplication sharedApplication].keyWindow;
    
    window=[[UIWindow alloc] initWithFrame:CGRectMake(0, 0, keyWindow.bounds.size.width, 62)];
    window.backgroundColor=nil;

    
    [window makeKeyAndVisible];
    [window setWindowLevel:UIWindowLevelStatusBar+1];

    
    [window addSubview:self];
    
    
    self.frame=CGRectMake(0, -62, window.bounds.size.width, 62);
    self.backgroundColor=[UIColor colorWithRed:63.0/255 green:77.0/255 blue:96.0/255 alpha:0.75];
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 16, 30, 30)];
    [self addSubview:imageView];
    
    type=[pushDict[@"aps"][@"type"] intValue];
    if(type==3)
        imageView.image=[UIImage imageNamed:@"KYCNeedDocuments"];
    else if(type==1 || type==5 || type==6)
        imageView.image=[UIImage imageNamed:@"KYCSuccess"];
    else if(type==2 || type==4)
        imageView.image=[UIImage imageNamed:@"KYCFailed"];
    
    label=[[UILabel alloc] initWithFrame:CGRectMake(55, 0, self.bounds.size.width-55-70, self.bounds.size.height)];
    label.numberOfLines=0;
    label.text=pushDict[@"aps"][@"alert"];
    label.font=[UIFont fontWithName:@"ProximaNova-Bold" size:14];
    label.textColor=[UIColor whiteColor];
    [self addSubview:label];
    
    skipButton=[UIButton buttonWithType:UIButtonTypeCustom];
    skipButton.frame=CGRectMake(self.bounds.size.width-70, 0, 70, self.bounds.size.height);
    [skipButton setTitle:@"SKIP" forState:UIControlStateNormal];
    skipButton.titleLabel.font=[UIFont fontWithName:@"ProximaNova-Regular" size:14];
    skipButton.titleLabel.textColor=[UIColor whiteColor];
    skipButton.alpha=0.6;
    [skipButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:skipButton];
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped)];
    [self addGestureRecognizer:gesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    return self;
}


-(void) userTapped
{
    if(type==1 || type==2 || type==3)
    {
        [self hide];
//        [LWKYCManager sharedInstance].viewController=[[UIApplication sharedApplication].keyWindow visibleViewController];
        [LWKYCManager sharedInstance].viewController=[keyWindow visibleViewController];
        
        [[LWKYCManager sharedInstance] manageKYCStatus];
        
//        LWKYCInvalidDocumentsPresenter *presenter=[[LWKYCInvalidDocumentsPresenter alloc] init];
//        presenter.delegate=self;
//        [[[UIApplication sharedApplication].keyWindow visibleViewController] presentViewController:presenter animated:YES completion:nil];
        
    }
    else if(type==6)
    {
        [self hide];

        //=[pushDict[@"aps"][@"Amount"] intValue];
        LWMyLykkeSuccessViewController *presenter=[LWMyLykkeSuccessViewController new];
        presenter.amount=[pushDict[@"aps"][@"amount"] stringValue];
        [presenter showInWindow:keyWindow];
        
    }
}

-(void) invalidDocumentsPresenterDismissed
{
//            [LWKYCManager sharedInstance].viewController=[[UIApplication sharedApplication].keyWindow visibleViewController];
//            [[LWKYCManager sharedInstance] manageKYCStatus];
}

-(void) show
{
//    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    
    
 
    
    self.center=CGPointMake(window.bounds.size.width/2, -self.bounds.size.height/2);
    [UIView animateWithDuration:0.5 animations:^{
        self.center=CGPointMake(window.bounds.size.width/2, self.bounds.size.height/2);
    } completion:^(BOOL finished){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hide];
        });
    
    }];
}

-(void) hide
{
    if(self.hidden)
        return;
//    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.center=CGPointMake(keyWindow.bounds.size.width/2, -self.bounds.size.height/2);
    } completion:^(BOOL finished){
        [self removeFromSuperview];
        self.hidden=YES;
        window.hidden=YES;
        window=nil;
        keyWindow=nil;
    }];

}

+(void) showPushNotification:(NSDictionary *) pushDict clickImmediately:(BOOL) flagClick
{
    UIViewController *topViewController=[[UIApplication sharedApplication].keyWindow visibleViewController];
    if([topViewController isKindOfClass:[LWKYCPendingPresenter class]])
        return;
    if([topViewController.class isSubclassOfClass:[LWAuthComplexPresenter class]]==NO)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [LWPushNotificationView showPushNotification:pushDict clickImmediately:flagClick];
        });
        return;
    }
    
    LWPushNotificationView *view=[[LWPushNotificationView alloc] initWithNotification:pushDict];
    if(flagClick)
        [view userTapped];
    else
        [view show];
}

-(void) orientationChanged
{
//    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    self.frame=CGRectMake(0, 0, keyWindow.bounds.size.width, self.bounds.size.height);
    label.frame=CGRectMake(label.frame.origin.x, 0, self.bounds.size.width-70, self.bounds.size.height);
    skipButton.center=CGPointMake(keyWindow.bounds.size.width-skipButton.bounds.size.width/2, self.bounds.size.height/2);
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
