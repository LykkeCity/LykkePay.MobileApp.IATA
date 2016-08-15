//
//  LWAuthEntryPointPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 09.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthEntryPointPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWTextField.h"
#import "LWTipsView.h"
#import "LWValidator.h"
#import "LWAuthManager.h"
#import "LWSMSCodeStepPresenter.h"
#import "LWRegisterBasePresenter.h"
#import "LWAuthenticationPresenter.h"
#import "LWUrlAddressPresenter.h"
#import "TKButton.h"
#import "ABPadLockScreen.h"
#import "LWCache.h"
#import "LWAnimatedView.h"
#import "LWIntroductionPresenter.h"
#import "UIViewController+Loading.h"
#import "UIView+Toast.h"
#import "LWProgressView.h"
#import "LWKeychainManager.h"
#import "LWRefundTransactionPresenter.h"

#import "LWTestBackupWordsPresenter.h"

typedef NS_ENUM(NSInteger, LWAuthEntryPointNextStep) {
    LWAuthEntryPointNextStepNone,
    LWAuthEntryPointNextStepLogin,
    LWAuthEntryPointNextStepRegister
};


@interface LWAuthEntryPointPresenter ()<
    LWTextFieldDelegate,
    LWTipsViewDelegate,
    ABPadLockScreenSetupViewControllerDelegate,
    LWIntroductionPresenterDelegate
> {
    LWTextField *emailTextField;
    LWTipsView  *tipsView;
    
    LWAuthEntryPointNextStep step;
    
    CGFloat keyboardHeight;
}

@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet TKContainer *emailTextFieldContainer;
@property (weak, nonatomic) IBOutlet TKButton    *proceedButton;
@property (weak, nonatomic) IBOutlet TKButton    *chooseServerButton;
@property (weak, nonatomic) IBOutlet TKContainer *tipsContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipsBottomConstraint;
@property (weak, nonatomic) IBOutlet LWProgressView *activityView;

// for IATA iPad
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginBottomConstraint;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (strong,nonatomic) IBOutlet UIButton *refundButton;


#pragma mark - Actions

- (IBAction)proceedButtonClick:(id)sender;

@end


@implementation LWAuthEntryPointPresenter


#pragma mark - TKPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    keyboardHeight=0;
    // init email field
    emailTextField = [LWTextField new];
    emailTextField.delegate = self;
    emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    emailTextField.placeholder = Localize(@"auth.email");
    [self.emailTextFieldContainer attach:emailTextField];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        self.observeKeyboardEvents=YES;
    }
    
    self.versionLabel.text=[LWCache currentAppVersion];
    
#ifdef PROJECT_IATA
#else
    [self.chooseServerButton setGrayPalette];
#endif
    
    // init tips
    tipsView = [LWTipsView new];
    tipsView.delegate = self;
    [self.tipsContainer attach:tipsView];
    
    [self.refundButton setTitle:@"Take refund" forState:UIControlStateNormal];
    [self.refundButton addTarget:self action:@selector(refundButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.refundButton.hidden=YES;
    
//    UIButton *testBackupButton=[UIButton buttonWithType:UIButtonTypeSystem]; //Testing
//    [testBackupButton setTitle:@"Test backup words" forState:UIControlStateNormal];
//    [testBackupButton sizeToFit];
//    testBackupButton.center=CGPointMake(200, 50);
//    [self.view addSubview:testBackupButton];
//    [testBackupButton addTarget:self action:@selector(testBackupButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

-(void) testBackupButtonPressed
{
    LWTestBackupWordsPresenter *test=[[LWTestBackupWordsPresenter alloc] init];
    [self.navigationController pushViewController:test animated:YES];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        CGRect rect=self.view.frame;
        rect.origin.y=0;
        self.view.frame=rect;
        self.logoView.translatesAutoresizingMaskIntoConstraints=NO;
        
    }
    [emailTextField resignFirstResponder];
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // hide navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    // keyboard observing
    self.observeKeyboardEvents = YES;
    // check button state
    [LWValidator setButton:self.proceedButton enabled:[self canProceed]];
    
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"IntroductionShown"]==NO)
    {
        [self showAnimatedView:NO];
    }
    else
    {
        [self textFieldDidChangeValue:emailTextField];
    }

    
#ifdef PROJECT_IATA
    self.chooseServerButton.hidden = YES;
#else

#ifdef TEST
    self.chooseServerButton.hidden = NO;
#else
    self.chooseServerButton.hidden = YES;
#endif
    
//    self.chooseServerButton.hidden = YES;
    
#endif
}

#ifdef PROJECT_IATA
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
#endif


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"IntroductionShown"]==NO)
    {
//        [self showAnimatedView];
    }
    else
    {
        [self textFieldDidChangeValue:emailTextField];
    }
}

- (void)localize {
#ifdef PROJECT_IATA
    [self.proceedButton setTitle:[Localize(@"auth.login") uppercaseString]
                        forState:UIControlStateNormal];
#else
//auth.login_signup
//    [self.proceedButton setTitle:[Localize(@"auth.signup") uppercaseString]
//                        forState:UIControlStateNormal];
    [self.proceedButton setTitle:[Localize(@"auth.login_signup") uppercaseString]
                        forState:UIControlStateNormal];
#endif
}

- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
    CGRect const frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

    keyboardHeight=frame.size.height;
    
    
    
//#ifdef PROJECT_IATA
//    BOOL isiPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
//    if (isiPad) {
//        [self.loginBottomConstraint setConstant:frame.size.height - 130];
//        [self.viewTopConstraint setConstant:-40];
//    }
//    else {
//        [self.tipsBottomConstraint setConstant:frame.size.height];
//    }
//#else
//    [self.tipsBottomConstraint setConstant:frame.size.height];
//#endif
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad && ([UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationLandscapeRight))
    {
        CGRect rect=self.view.frame;
        rect.origin.y=-140;
        self.view.frame=rect;
        
        
        self.logoView.translatesAutoresizingMaskIntoConstraints=YES;
        self.logoView.frame=CGRectMake(0, 0, 50, 50);
        self.logoView.center=CGPointMake(self.view.bounds.size.width/2, 240);
    }

    [self animateConstraintChanges];
}

- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
//#ifdef PROJECT_IATA
//    BOOL isiPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
//    if (isiPad) {
//        [self.loginBottomConstraint setConstant:0];
//        [self.viewTopConstraint setConstant:30];
//    }
//    else {
//        [self.tipsBottomConstraint setConstant:0];
//    }
//#else
//    [self.tipsBottomConstraint setConstant:0];
//#endif
    keyboardHeight=0;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        CGRect rect=self.view.frame;
        rect.origin.y=0;
        self.view.frame=rect;
        self.logoView.translatesAutoresizingMaskIntoConstraints=NO;


    }


    [self animateConstraintChanges];
}


#pragma mark - LWAuthStepPresenter

- (LWAuthStep)stepId {
    return LWAuthStepEntryPoint;
}


#pragma mark - Utils

- (BOOL)canProceed {
    BOOL canProceed = emailTextField.isValid && (step != LWAuthEntryPointNextStepNone);
    return canProceed;
}


#pragma mark - Actions

- (void)proceedButtonClick:(id)sender {
    LWAuthNavigationController *nav = (LWAuthNavigationController *)self.navigationController;

    switch (step) {
        case LWAuthEntryPointNextStepLogin: {
            [nav navigateToStep:LWAuthStepAuthentication
               preparationBlock:^(LWAuthStepPresenter *presenter) {
                ((LWAuthenticationPresenter *)presenter).email = emailTextField.text;
            }];
            break;
        }
        case LWAuthEntryPointNextStepRegister: {
            [nav navigateToStep:LWAuthStepSMSCode
               preparationBlock:^(LWAuthStepPresenter *presenter) {
                   NSString *email = emailTextField.text;
                   ((LWSMSCodeStepPresenter *)presenter).email = email;
               }];
            break;
        }
        default: {
            NSAssert(0, @"Invalid case.");
            break;
        }
    }
}

- (IBAction)proceedChooseServerClick:(id)sender {
    LWUrlAddressPresenter *address = [LWUrlAddressPresenter new];
    [self.navigationController pushViewController:address animated:YES];
}

-(void) refundButtonPressed
{
    LWRefundTransactionPresenter *presenter=[[LWRefundTransactionPresenter alloc] init];
    presenter.email=emailTextField.text;
    [self.navigationController pushViewController:presenter animated:YES];
}

#pragma mark - LWTextFieldDelegate

- (void)textFieldDidChangeValue:(LWTextField *)textField {
    if (!self.isVisible) { // prevent from being processed if controller is not presented
        return;
    }
    emailTextField.valid = [LWValidator validateEmail:textField.text];
    // reset next step
    step = LWAuthEntryPointNextStepNone;
    
    if(textField.text && self.refundButton && textField.text.length)
    {
        if([[LWKeychainManager instance] encodedPrivateKeyForEmail:textField.text])
        {
            self.refundButton.hidden=NO;
        }
        else
            self.refundButton.hidden=YES;
    }
    
#ifdef PROJECT_IATA
    if (emailTextField.isValid) {
        step = LWAuthEntryPointNextStepLogin;
        // check button state
        [LWValidator setButton:self.proceedButton enabled:[self canProceed]];
    }
#else
    // check button state
    [LWValidator setButton:self.proceedButton enabled:[self canProceed]];
    
    if (emailTextField.isValid) {
        // show activity
        [self.activityView startAnimating];
        // send request
        [[LWAuthManager instance] requestEmailValidation:emailTextField.text];
    }
#endif
}


#pragma mark - LWTipsViewDelegate

- (void)tipsViewDidPress:(LWTipsView *)view {
    
    
    [self showAnimatedView:YES];
    
    // ...
}

-(void) showAnimatedView:(BOOL) animated
{
    LWIntroductionPresenter *intro=[[LWIntroductionPresenter alloc] init];
    intro.delegate=self;
    intro.view.frame=self.view.bounds;
    UIWindow *window=[UIApplication sharedApplication].windows[0];
    
    if(animated)
    {
        [window addSubview:intro.view];

        intro.view.center=CGPointMake(intro.view.center.x, intro.view.center.y+self.view.bounds.size.height);
        
        [UIView animateWithDuration:0.5 animations:^{
            self.view.center=CGPointMake(self.view.center.x, self.view.center.y-self.view.bounds.size.height);
            intro.view.frame=window.bounds;;

        } completion:^(BOOL finished){
            [intro.view removeFromSuperview];
            window.rootViewController=intro;
            
        }];
    }
    else
    {
        self.view.center=CGPointMake(self.view.center.x, self.view.center.y-self.view.bounds.size.height);
        window.rootViewController=intro;
    }

    return;
}


-(void) introductionPresenterShouldDismiss:(LWIntroductionPresenter *) intro
{
    UIWindow *window=[UIApplication sharedApplication].windows[0];
    [window addSubview:self.view];
    self.view.center=CGPointMake(window.bounds.size.width/2, window.bounds.size.height/2-window.bounds.size.height);
    [UIView animateWithDuration:0.5 animations:^{

        self.view.center=CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        intro.view.center=CGPointMake(intro.view.center.x, intro.view.center.y+intro.view.bounds.size.height);
    } completion:^(BOOL finished){
        [intro.view removeFromSuperview];
        [self.view removeFromSuperview];
        
        window.rootViewController=self.navigationController;

        intro.delegate=nil;
        
    }];

}




#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didCheckRegistration:(BOOL)isRegistered email:(NSString *)email {
    [self.activityView stopAnimating];
    
    if (isRegistered) {
        step = LWAuthEntryPointNextStepLogin;
        [self.proceedButton setTitle:[Localize(@"auth.login") uppercaseString]
                            forState:UIControlStateNormal];
    }
    else {
        step = LWAuthEntryPointNextStepRegister;
        [self.proceedButton setTitle:[Localize(@"auth.signup") uppercaseString]
                            forState:UIControlStateNormal];
    }
    // check button state
    [LWValidator setButton:self.proceedButton enabled:[self canProceed]];
    
    // request again if email changed
    if (![email isEqualToString:emailTextField.text]) {
        [self textFieldDidChangeValue:emailTextField];
    }
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self.activityView stopAnimating];
    
    if(reject==nil)
    {
        [self.view makeToast:Localize(@"errors.network.connection") duration:1 position:[NSValue valueWithCGPoint:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height-keyboardHeight-30)]];
        return;
        
    }
    
    
    step = LWAuthEntryPointNextStepRegister;
    // check button state
    [LWValidator setButton:self.proceedButton enabled:[self canProceed]];
}


#pragma mark - ABPadLockScreenViewControllerDelegate

- (void)padLockScreenSetupViewController:(ABPadLockScreenSetupViewController *)controller didSetPin:(NSString *)pin {
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end
