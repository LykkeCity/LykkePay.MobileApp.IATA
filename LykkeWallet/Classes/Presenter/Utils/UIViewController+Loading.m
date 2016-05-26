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


@implementation UIViewController (Loading)


- (void)setLoading:(BOOL)loading {
    if (loading) {
        [self.view endEditing:YES];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.dimBackground = YES;
        hud.mode = MBProgressHUDModeIndeterminate;
    }
    else {
        MBProgressHUD *hud = [self hud];
        if (hud) {
            [hud hide:YES];
        }
    }
}

- (MBProgressHUD *)hud {
    return [MBProgressHUD HUDForView:self.navigationController.view];
}

- (void)showReject:(NSDictionary *)reject response:(NSURLResponse *)response {
    [self setLoading:NO];
    
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
    
    NSString *error = [NSString stringWithFormat:@"Error: %@. Code: %@. Login: %@. DateTime: %@", message, code, email, time];
    
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
    
    if (response && [LWAuthManager isInternalServerError:response]) {
        message = [NSString stringWithFormat:Localize(@"errors.server.problems")];
    }
    
    LWErrorView *errorView = [LWErrorView modalViewWithDescription:message];
    [errorView setFrame:self.navigationController.view.bounds];
    
    // animation
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [errorView.layer addAnimation:transition forKey:nil];
    
    // showing modal view
    [self.navigationController.view addSubview:errorView];
}

@end
