//
//  LWAuthPINEnterPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 17.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthPINEnterPresenter.h"
#import "LWAuthNavigationController.h"
#import "ABPadLockScreen.h"
#import "LWPacketPinSecurityGet.h"
#import "LWFingerprintHelper.h"
#import "UIViewController+Loading.h"

#import <AFNetworking/AFNetworking.h>

static int const kAllowedAttempts = 3;

@interface LWAuthPINEnterPresenter () <ABPadLockScreenViewControllerDelegate> {
    ABPadLockScreenViewController *pinController;
}


#pragma mark - Utils

- (void)validateUser;

@end


@implementation LWAuthPINEnterPresenter


#pragma mark - LWAuthStepPresenter

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // adjust pin controller frame
    if (!pinController) {
        pinController = [[ABPadLockScreenViewController alloc] initWithDelegate:self
                                                                     complexPin:NO];
        [pinController cancelButtonDisabled:YES];
        [pinController setAllowedAttempts:kAllowedAttempts];

        pinController.modalPresentationStyle = UIModalPresentationFullScreen;
        pinController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        ABPadLockScreenView *view = (ABPadLockScreenView *)pinController.view;
        view.enterPasscodeLabel.text = Localize(@"ABPadLockScreen.pin.enter");

        __block UIViewController *mainController = self;
        __block UINavigationController *navigation = self.navigationController;

        pinController.validateBlock = ^BOOL(NSString *pin_) {

            // configure URL
            __block LWPacketPinSecurityGet *pack = [LWPacketPinSecurityGet new];
            pack.pin = [pin_ copy];
        
            NSURL *url = [NSURL URLWithString:pack.urlBase];
            AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]
                                             initWithBaseURL:url];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            NSDictionary *headers = [pack headers];
            for (NSString *key in headers.allKeys) {
                [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
            }
            
            [manager GET:pack.urlRelative
                parameters:nil
                progress:nil
                success:^(NSURLSessionTask *task, id responseObject) {
                    [pack parseResponse:responseObject error:nil];
                    dispatch_semaphore_signal(semaphore);
                }
                failure:^(NSURLSessionTask *operation, NSError *error) {
                    if (![LWAuthManager isAuthneticationFailed:operation.response]) {
                        NSMutableDictionary *errorInfo = [[NSMutableDictionary alloc]
                                                          initWithObjects:@[ error.localizedDescription, [NSNumber numberWithInt:-1]] forKeys:@[ @"Message", @"Code" ]];
                        [mainController showReject:errorInfo response:operation.response];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [mainController setLoading:NO];
                        [((LWAuthNavigationController *)navigation) logout];
                    });

                    pack = nil;
                    dispatch_semaphore_signal(semaphore);
                }];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
            BOOL const result = (pack && pack.isPassed);
            return result;
        };
    }
    
    // run fingerprint validation
    [self.navigationController presentViewController:pinController animated:NO completion:^{
        [self validateUser];
    }];
}

#ifdef PROJECT_IATA
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
#endif

- (void)localize {
}

- (LWAuthStep)stepId {
    return LWAuthStepValidatePIN;
}


#pragma mark - ABPadLockScreenSetupViewControllerDelegate

- (BOOL)padLockScreenViewController:(ABPadLockScreenViewController *)controller validatePin:(NSString*)pin {

    [pinController clearPin]; // don't forget to clear PIN data

    // validate pin
    [self setLoading:YES];
    BOOL const result = (controller.validateBlock ? controller.validateBlock(pin) : NO);
    [self setLoading:NO];

    return result;
}

- (void)unlockWasSuccessfulForPadLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController {
    
    [pinController dismissViewControllerAnimated:NO completion:^{
        [((LWAuthNavigationController *)self.navigationController) setRootMainTabScreen];
    }];
}

- (void)unlockWasUnsuccessful:(NSString *)falsePin afterAttemptNumber:(NSInteger)attemptNumber padLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController {

}

- (void)unlockWasCancelledForPadLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController {
    [pinController dismissViewControllerAnimated:NO completion:^{
        [((LWAuthNavigationController *)self.navigationController) logout];
    }];
}

- (void)attemptsExpiredForPadLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController {
    [pinController dismissViewControllerAnimated:NO completion:^{
        [((LWAuthNavigationController *)self.navigationController) logout];
    }];
}


#pragma mark - Utils

- (void)validateUser {

    [LWFingerprintHelper
     validateFingerprintTitle:Localize(@"auth.validation.fingerpring")
     ok:^(void) {
         [pinController dismissViewControllerAnimated:NO completion:^{
             [((LWAuthNavigationController *)self.navigationController) setRootMainTabScreen];
         }];
     }
     bad:^(void) {
     }
     unavailable:^(void) {
     }];
}

@end
