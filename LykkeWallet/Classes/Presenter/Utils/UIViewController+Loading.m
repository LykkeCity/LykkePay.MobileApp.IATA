//
//  UIViewController+Loading.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 16.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "UIViewController+Loading.h"
#import "LWKeychainManager.h"
#import "LWAuthManager.h"
#import "LWCache.h"
#import "LWErrorView.h"
#import "Macro.h"
#import "UIView+Toast.h"
#import "LWProgressView.h"


@implementation UIViewController (Loading)



- (void)setLoading:(BOOL)loading {
    if (loading) {
        [self.view endEditing:YES];
        
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        hud.dimBackground = YES;
//        hud.mode = MBProgressHUDModeIndeterminate;
        
//        [LWProgressView showInView:self.navigationController.view];
        [LWProgressView showInView:self.view];
        
    }
    else {
        
        [LWProgressView hide];
//        MBProgressHUD *hud = [self hud];
//        if (hud) {
//            [hud hide:YES];
//        }
    }
}


- (MBProgressHUD *)hud {
    return [MBProgressHUD HUDForView:self.navigationController.view];
}

- (void)showReject:(NSDictionary *)reject response:(NSURLResponse *)response {
    [self setLoading:NO];
    
    if([reject[@"Code"] intValue]==6)
    {
        [self showNeedUpdateError:reject[@"Message"]];
        return;
    }
    
//    NSString *message = [reject objectForKey:kErrorMessage];    //Prevent showing error if connection to server was terminated when app was suspended
//    NSNumber *code = [reject objectForKey:kErrorCode];
//    if(!message && !code)
//        return;
    
    if ([LWCache instance].debugMode) {
        [self showDebugError:reject response:response];
    }
    else {
        [self showReleaseError:reject response:response];
    }
}

- (void)showReject:(NSDictionary *)reject response:(NSURLResponse *)response code:(NSInteger)code willNotify:(BOOL)willNotify {
    if (code == NSURLErrorNotConnectedToInternet) {
        [self setLoading:NO];
        
        if (willNotify) {
            [self.navigationController.view makeToast:Localize(@"errors.network.connection")];
        }
    }
    else {
        [self showReject:reject response:response];
    }
}


#pragma mark - Utils

- (NSString *)currentUTC {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    // Add this part to your code
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:timeZone];
    
    NSDate *now = [NSDate date];
    NSString *result = [formatter stringFromDate:now];
    return result;
}

- (void)showDebugError:(NSDictionary *)reject response:(NSURLResponse *)response {
    NSString *message = [reject objectForKey:kErrorMessage];
    NSNumber *code = [reject objectForKey:kErrorCode];
    
    
    NSString *email = [[LWKeychainManager instance] login];
    NSString *time = [self currentUTC];
    
    if (response && [LWAuthManager isInternalServerError:response]) {
        message = [NSString stringWithFormat:@"Internal server error! Requested URL: %@", [response URL].absoluteString];
        code = [NSNumber numberWithInt:500];
    }
    else if (response && [LWAuthManager isNotOk:response]) {
        message = [NSString stringWithFormat:@"Http error! Requested URL: %@", [response URL].absoluteString];
        NSHTTPURLResponse* urlResponse = (NSHTTPURLResponse*)response;
        code = [NSNumber numberWithInteger:urlResponse.statusCode];
    }
    
    NSString *error = [NSString stringWithFormat:@"Error: %@. Code: %@. Login: %@. DateTime: %@. %@", message, code, email, time, [LWCache currentAppVersion]];
    
    UIAlertController *ctrl = [UIAlertController
                               alertControllerWithTitle:Localize(@"utils.error")
                               message:error
                               preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:Localize(@"utils.ok")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [ctrl dismissViewControllerAnimated:YES
                                                                                  completion:nil];
                                                     }];
    [ctrl addAction:actionOK];
    [self presentViewController:ctrl animated:YES completion:nil];
}

- (void)showReleaseError:(NSDictionary *)reject response:(NSURLResponse *)response {
    NSString *message = [reject objectForKey:kErrorMessage];
    
    UIWindow *window=self.view.window;
    
    if (response && [LWAuthManager isInternalServerError:response]) {
        message = [NSString stringWithFormat:Localize(@"errors.server.problems")];
    }
    if(!message)
        message=@"Unknown server error";
    LWErrorView *errorView = [LWErrorView modalViewWithDescription:message];
    [errorView setFrame:window.bounds];
    
    // animation
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [errorView.layer addAnimation:transition forKey:nil];
    
    // showing modal view
    [window addSubview:errorView];
}

-(void) showNeedUpdateError:(NSString *) message
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"LYKKE" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Update", nil];
    [alert show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/us/app/lykke-wallet/id1112839581"]];
    
}

-(void) adjustThinLines
{
    [self checkLinesInView:self.view];
}

-(void) checkLinesInView:(UIView *) view
{
    for(UIView *v in view.subviews)
    {
        if([v isKindOfClass:[UIView class]])
        {
            for(NSLayoutConstraint *c in v.constraints)
            {
                if(c.firstAttribute==NSLayoutAttributeWidth && c.constant==1)
                    c.constant=0.5;
                if(c.firstAttribute==NSLayoutAttributeHeight && c.constant==1)
                    c.constant=0.5;
            }
            
        }
        [self checkLinesInView:v];
            
    }
}


@end
