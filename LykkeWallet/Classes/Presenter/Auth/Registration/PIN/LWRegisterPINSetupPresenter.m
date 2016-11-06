//
//  LWRegisterPINSetupPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 17.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWRegisterPINSetupPresenter.h"
#import "LWAuthNavigationController.h"
#import "ABPadLockScreen.h"


@interface LWRegisterPINSetupPresenter ()<ABPadLockScreenSetupViewControllerDelegate> {
    ABPadLockScreenSetupViewController *pinController;
    
    NSString *pin;
    BOOL     pinDidSendToServer;
}

@property (weak, nonatomic) IBOutlet UIView  *maskingView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end


@implementation LWRegisterPINSetupPresenter


#pragma mark - LWAuthStepPresenter

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    // set masking view visibility
    self.maskingView.hidden = pinDidSendToServer;
    // adjust pin controller frame
    if (!pinController) {
        pinController = [[ABPadLockScreenSetupViewController alloc] initWithDelegate:self
                                                                          complexPin:NO];
        [pinController cancelButtonDisabled:YES];
        
        pinController.modalPresentationStyle = UIModalPresentationFullScreen;
        pinController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    if (!pin) {
        [self presentViewController:pinController animated:YES completion:nil];
    }
}

- (void)localize {
    self.titleLabel.text = [Localize(@"register.pin.setup.ok.title") uppercaseString];
    self.textLabel.text = Localize(@"register.pin.setup.ok.text");
    self.okButton.titleLabel.text = Localize(@"register.pin.setup.ok.okButton");
}

- (LWAuthStep)stepId {
    return LWAuthStepRegisterPINSetup;
}

#ifdef PROJECT_IATA
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
#endif


#pragma mark - Actions

- (IBAction)okButtonClick:(id)sender {
    [((LWAuthNavigationController *)self.navigationController) setRootMainTabScreen];
}


#pragma mark - ABPadLockScreenSetupViewControllerDelegate

- (void)padLockScreenSetupViewController:(ABPadLockScreenSetupViewController *)controller didSetPin:(NSString *)pin_ {
    [controller dismissViewControllerAnimated:YES completion:nil]; // dismiss
    [pinController clearPin]; // don't forget to clear PIN data
    // save pin
    pin = [pin_ copy];
    // request PIN setup
    [[LWAuthManager instance] requestPinSecuritySet:pin];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidSetPin:(LWAuthManager *)manager {
    pinDidSendToServer = YES;
    // hide masking view
    self.maskingView.hidden = YES;
}

@end
