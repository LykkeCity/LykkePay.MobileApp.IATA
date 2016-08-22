//
//  LWAuthenticationPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 20.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWAuthenticationPresenter.h"
#import "LWKYCPendingPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWAuthenticationData.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "LWDeviceInfo.h"
#import "UIViewController+Loading.h"
#import "LWPrivateKeyManager.h"
#import "UIView+Toast.h"
#import "LWCommonButton.h"
#import "LWPINPresenter.h"
#import "LWSMSCodeCheckPresenter.h"

#import "LWCache.h"

#import "LWRestorePasswordWordsPresenter.h"
#import "LWIPadModalNavigationControllerViewController.h"


@interface LWAuthenticationPresenter () <UITextFieldDelegate, LWAuthManagerDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet LWCommonButton *loginButton;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIView *buttonsContainer;

@property (weak, nonatomic) IBOutlet UIButton *resetPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *emailHintButton;
@property (weak, nonatomic) IBOutlet UIImageView *passwordInvalidImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceBetweenButtonsConstraint;

//@property (strong, nonatomic) NSLayoutConstraint *distanceBetweenButtonsConstraint2;

@property (strong,nonatomic) NSLayoutConstraint *resetPasswordWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;

@end


@implementation LWAuthenticationPresenter 

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // init fields
    
    _passwordField.placeholder = Localize(@"auth.password");
    _passwordField.secureTextEntry = YES;
    _passwordField.delegate = self;
    
    self.resetPasswordWidthConstraint=[NSLayoutConstraint constraintWithItem:self.resetPasswordButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [self.resetPasswordButton addConstraint:self.resetPasswordWidthConstraint];
    
    
//    [self.buttonsContainer removeConstraint:self.distanceBetweenButtonsConstraint];
    
//    self.distanceBetweenButtonsConstraint2=[NSLayoutConstraint constraintWithItem:self.resetPasswordButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.emailHintButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
//    [self.buttonsContainer addConstraint:self.distanceBetweenButtonsConstraint2];

    self.distanceBetweenButtonsConstraint.constant=0;
    
    self.passwordInvalidImageView.hidden=YES;
    
    self.loginButton.colored=YES;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.loginButton.enabled=[self canProceed];
//    [LWValidator setButton:self.loginButton enabled:[self canProceed]];
    
    // load email
    
    // focus first name
    
    self.observeKeyboardEvents=YES;
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_passwordField becomeFirstResponder];
    self.title = Localize(@"title.authentication");

//    LWSMSCodeCheckPresenter *pin=[[LWSMSCodeCheckPresenter alloc] init];
//    [self.navigationController pushViewController:pin animated:YES];
//    return;


}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.loginButton.layer.cornerRadius=self.loginButton.bounds.size.height/2;
}


#pragma mark - LWTextFieldDelegate

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text=[textField.text stringByReplacingCharactersInRange:range withString:string];
//    [LWValidator setButton:self.loginButton enabled:[self canProceed]];
    self.passwordInvalidImageView.hidden=YES;
    self.loginButton.enabled=[self canProceed];
    return NO;
}


//- (void)textFieldDidChangeValue:(LWTextField *)textFieldInput {
//    if (!self.isVisible) { // prevent from being processed if controller is not presented
//        return;
//    }
//    // check button state
//    [LWValidator setButton:self.loginButton enabled:[self canProceed]];
//}


#pragma mark - Private

- (BOOL)canProceed {
    
    BOOL isValidPassword = [LWValidator validatePassword:_passwordField.text];
    
    return isValidPassword;
}


#pragma mark - Utils

- (IBAction)loginClicked:(id)sender {
    [self.view endEditing:YES];
    if ([self canProceed]) {
        [self setLoading:YES];
        
        LWAuthenticationData *data = [LWAuthenticationData new];
        data.email = self.email;
        data.password = _passwordField.text;
        data.clientInfo = [[LWDeviceInfo instance] clientInfo];
        
        [[LWAuthManager instance] requestAuthentication:data];
    }
}

-(IBAction)restorePasswordClicked:(id)sender
{
    LWRestorePasswordWordsPresenter *presenter=[[LWRestorePasswordWordsPresenter alloc] init];
    presenter.email=self.email;
//    [self.navigationController pushViewController:presenter animated:YES];
    
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone)
        [self.navigationController pushViewController:presenter animated:YES];
    else
    {
        LWIPadModalNavigationControllerViewController *navigationController =
        [[LWIPadModalNavigationControllerViewController alloc] initWithRootViewController:presenter];
        navigationController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        navigationController.transitioningDelegate=navigationController;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }

    
    
}

-(IBAction)sendHintPressed:(id)sender
{
    [self.view endEditing:YES];
      [self.navigationController.view makeToast:Localize(@"wallets.bitcoin.sendemail")];
}

- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
    
//    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
//    {
//        [super observeKeyboardWillShowNotification:notification];
//        return;
//    }
//    if([UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationLandscapeRight)
//    {
//        self.scrollView.contentOffset=CGPointMake(0, 80);
//        self.scrollView.scrollEnabled=NO;
//    }as
    CGRect const frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.scrollViewBottomConstraint.constant=frame.size.height;

}

- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
    
    self.scrollViewBottomConstraint.constant=0;
    
//    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
//    {
//        [super observeKeyboardWillShowNotification:notification];
//        return;
//    }
//    self.scrollView.contentOffset=CGPointMake(0, 0);
//    
//    self.scrollView.contentInset = UIEdgeInsetsZero;
//    self.scrollView.scrollEnabled=YES;
}



#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidAuthenticate:(LWAuthManager *)manager KYCStatus:(NSString *)status isPinEntered:(BOOL)isPinEntered {
    [self setLoading:NO];
    
    LWAuthNavigationController *navController = (LWAuthNavigationController *)self.navigationController;
    [navController navigateKYCStatus:status
                          isPinEntered:isPinEntered
                        isAuthentication:YES];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
   // [self showReject:reject response:context.task.response];
    [self setLoading:NO];
    self.resetPasswordWidthConstraint.active=NO;
    self.distanceBetweenButtonsConstraint.constant=25;
    self.passwordInvalidImageView.hidden=NO;
    [self.view layoutSubviews];
}

@end
