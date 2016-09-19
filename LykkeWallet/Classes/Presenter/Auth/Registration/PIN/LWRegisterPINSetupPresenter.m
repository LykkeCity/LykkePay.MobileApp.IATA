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
#import "LWValidator.h"
#import "UIViewController+Loading.h"
#import "LWGenerateKeyPresenter.h"

#import "LWPINPresenter.h"


#import "LWKeychainManager.h"


@interface LWRegisterPINSetupPresenter ()<ABPadLockScreenSetupViewControllerDelegate> {
//    ABPadLockScreenSetupViewController *pinController;
  
    LWPINPresenter *pinController;
    NSString *pin;
    BOOL     pinDidSendToServer;
    UIImageView *progressView;
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
//    [self setLoading:!pinDidSendToServer];

    // adjust pin controller frame
    if (!pinController) {
        
        pinController=[LWPINPresenter new];
        pinController.pinType=PIN_TYPE_ENTER;
        pinController.view.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        pinController.pinEnteredBlock=^(NSString *pin_){
            pin=pin_;
            [self setLoading:YES];
            [[LWAuthManager instance] requestPinSecuritySet:pin_];
            
            
        
        };
//        pinController = [[ABPadLockScreenSetupViewController alloc] initWithDelegate:self
//                                                                          complexPin:NO];
//        [pinController cancelButtonDisabled:YES];
//        
//        pinController.modalPresentationStyle = UIModalPresentationFullScreen;
//        pinController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        progressView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
//        progressView.image=[UIImage imageNamed:@"RegisterLineStep4.png"];
//        progressView.contentMode=UIViewContentModeCenter;
//        progressView.hidden=YES;
//        [pinController.view addSubview:progressView];
        
        
    }
    if (!pin) {
//        [self presentViewController:pinController animated:YES completion:nil];
        pinController.view.frame=self.view.bounds;
        [self.view addSubview:pinController.view];
        [self addChildViewController:pinController];
    }
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    progressView.center=CGPointMake(self.view.bounds.size.width/2, 40);
    progressView.hidden=NO;
    [LWValidator setButton:self.okButton enabled:YES];

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

//- (void)padLockScreenSetupViewController:(ABPadLockScreenSetupViewController *)controller didSetPin:(NSString *)pin_ {
//    [controller dismissViewControllerAnimated:YES completion:nil]; // dismiss
//    [pinController clearPin]; // don't forget to clear PIN data
//    // save pin
//    
//    pin = [pin_ copy];
//    
//    // request PIN setup
//    [[LWAuthManager instance] requestPinSecuritySet:pin];
//}


#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidSetPin:(LWAuthManager *)manager {
    pinDidSendToServer = YES;
    // hide masking view
//    self.maskingView.hidden = YES;
    [self setLoading:NO];
    
    [[LWAuthManager instance] requestMyLykkeSettings];
    LWGenerateKeyPresenter *presenter=[[LWGenerateKeyPresenter alloc] init];
    [self.navigationController pushViewController:presenter animated:YES];
    
}

-(void) authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context
{
    [self setLoading:NO];
    [self showReject:reject response:context.task.response];
}

@end
