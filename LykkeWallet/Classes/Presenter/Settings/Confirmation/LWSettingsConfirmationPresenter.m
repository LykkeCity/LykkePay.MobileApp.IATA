//
//  LWSettingsConfirmationPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 08.01.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWSettingsConfirmationPresenter.h"
#import "ABPadLockScreen.h"
#import "LWFingerprintHelper.h"
#import "LWPacketPinSecurityGet.h"
#import "UIViewController+Loading.h"

#import <AFNetworking/AFNetworking.h>


@interface LWSettingsConfirmationPresenter () <ABPadLockScreenViewControllerDelegate> {
    ABPadLockScreenViewController *pinController;
}


#pragma mark - Utils

- (void)validateUser;

@end


#warning TODO: refactoring because of copying LWAuthPINEnterPresenter
@implementation LWSettingsConfirmationPresenter


static int const kAllowedAttempts = 3;


#pragma mark - LWAuthStepPresenter

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
        //__block UINavigationController *navigation = self.navigationController;
        
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
                     });
                     
                     pack = nil;
                     dispatch_semaphore_signal(semaphore);
                 }];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            BOOL const result = (pack && pack.isPassed);
            return result;
        };
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    // run fingerprint validation
    [self.navigationController presentViewController:pinController
                                            animated:NO completion:^{
                                                [self validateUser];
                                            }];
}

#ifdef PROJECT_IATA
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
#endif


#pragma mark - ABPadLockScreenViewControllerDelegate

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
        [self.delegate operationConfirmed:self];
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (void)unlockWasUnsuccessful:(NSString *)falsePin afterAttemptNumber:(NSInteger)attemptNumber padLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController {
    
}

- (void)unlockWasCancelledForPadLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController {
    [pinController dismissViewControllerAnimated:NO completion:^{
        [self.delegate operationRejected];
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (void)attemptsExpiredForPadLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController {
    [pinController dismissViewControllerAnimated:NO completion:^{
        [self.delegate operationRejected];
        [self.navigationController popViewControllerAnimated:NO];
    }];
}


#pragma mark - Utils

- (void)validateUser {

    NSString *title = Localize(@"settings.cell.pin.change.title");
    [LWFingerprintHelper validateFingerprintTitle:title ok:^{
        [pinController dismissViewControllerAnimated:NO completion:^{
            [self.delegate operationConfirmed:self];
            [self.navigationController popViewControllerAnimated:NO];
        }];
    } bad:^{
        // continue working with pin
    } unavailable:^{
        // do nothing - input pin
    }];
}

@end
