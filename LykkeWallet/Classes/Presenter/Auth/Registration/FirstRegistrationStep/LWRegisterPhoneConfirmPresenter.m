//
//  LWRegisterPhoneConfirmPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 07.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWRegisterPhoneConfirmPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWAuthManager.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "LWConstants.h"
#import "TKButton.h"
#import "UIViewController+Loading.h"
#import "UIView+Toast.h"
#import "LWSMSTimerView.h"
#import "LWRequestCallMessageView.h"



@interface LWRegisterPhoneConfirmPresenter () <LWTextFieldDelegate, LWSMSTimerViewDelegate> {
    LWTextField *codeTextField;
    CGFloat keyboardHeight;
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet TKContainer *codeContainer;
@property (weak, nonatomic) IBOutlet TKButton    *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel     *statusLabel;
@property (weak, nonatomic) IBOutlet LWSMSTimerView *notReceivedSMSView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proceedWidthConstraint;

@end


@implementation LWRegisterPhoneConfirmPresenter


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.observeKeyboardEvents=YES;

    [codeTextField becomeFirstResponder];
    self.title = Localize(@"register.title");
    
    _notReceivedSMSView.delegate=self;
    
    if([_notReceivedSMSView isTimerRunnig]==NO && _flagHaveSentSMS==NO)
    {
        [self setLoading:YES];
        [[LWAuthManager instance] requestVerificationPhone:self.phone];
        _flagHaveSentSMS=YES;
    }


}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([UIScreen mainScreen].bounds.size.width==320)
        _proceedWidthConstraint.constant=280;

    
    keyboardHeight=0;
    
    
    // init email field
    codeTextField = [LWTextField new];
    codeTextField.delegate = self;
    codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    codeTextField.placeholder = Localize(@"register.phone.code.placeholder");
    codeTextField.viewMode = UITextFieldViewModeNever;
    [self.codeContainer attach:codeTextField];
    
    
    
    [LWValidator setButton:self.confirmButton enabled:NO];
    
    [_notReceivedSMSView setTitle:@"Haven't receive the code?"];
    _flagHaveSentSMS=NO;
    
//#ifdef PROJECT_IATA
//#else
//    [self.confirmButton setGrayPalette];
//#endif
    
    
}

- (void)localize {
    
    self.statusLabel.text = [NSString stringWithFormat:Localize(@"register.phone.sent"), self.phone];
    
    
    [self.confirmButton setTitle:Localize(@"register.sms.confirm")
                        forState:UIControlStateNormal];
}

- (void)colorize {
    UIColor *color = [UIColor colorWithHexString:kMainElementsColor];
    
}



#pragma mark - LWTextFieldDelegate

- (void)textFieldDidChangeValue:(LWTextField *)textField {
    // prevent from being processed if controller is not presented
    if (!self.isVisible) {
        return;
    }
    
}



-(BOOL) textField:(LWTextField *)textField shouldChangeCharsInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString=[textField.text stringByReplacingCharactersInRange:range withString:string];
    if(newString.length>4)
        return NO;
    if(newString.length==4)
        self.confirmButton.enabled=YES;
    else
        self.confirmButton.enabled=NO;
    
    [LWValidator setButton:self.confirmButton enabled:self.confirmButton.enabled];
    
    return YES;
}

#pragma mark - Outlets

- (IBAction)confirmClicked:(id)sender {
    if (!(codeTextField.text == nil || codeTextField.text.length <= 0)) {
        [self setLoading:YES];
        [[LWAuthManager instance] requestVerificationPhone:self.phone forCode:codeTextField.text];
    }
}

- (void)smsTimerViewPressedResend:(LWSMSTimerView *)view
{
    
    [self setLoading:YES];
    [[LWAuthManager instance] requestVerificationPhone:self.phone];


    
//    [self.navigationController popViewControllerAnimated:YES];
}


-(void) smsTimerViewPressedRequestVoiceCall:(LWSMSTimerView *)view
{
    [self setLoading:YES];
    [[LWAuthManager instance] requestVoiceCall];
    
}

#pragma mark - LWAuthStepPresenter

- (LWAuthStep)nextStep {
    return LWAuthStepRegisterFullName;
}

- (LWAuthStep)stepId {
    return LWAuthStepSMSCode;
}


#pragma mark - Utils

- (BOOL)canProceed {
    BOOL canProceed = codeTextField.text.length > 0;
    return canProceed;
}

- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
    CGRect const frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardHeight=frame.size.height;

    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
    {
        [super observeKeyboardWillShowNotification:notification];
        return;
    }
    
    if([UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationLandscapeRight)
    {
        self.scrollView.contentOffset=CGPointMake(0, 100);
        self.scrollView.scrollEnabled=NO;
    }
    
}

- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
    keyboardHeight=0;
    
    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
    {
        [super observeKeyboardWillShowNotification:notification];
        return;
    }
    self.scrollView.contentOffset=CGPointMake(0, 0);
    
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollEnabled=YES;
}



#pragma mark - LWAuthManagerDelegate

-(void) authManagerDidRequestVoiceCall:(LWAuthManager *)manager
{
    [self setLoading:NO];
    
    LWRequestCallMessageView *vvv=[[NSBundle mainBundle] loadNibNamed:@"LWRequestCallMessageView" owner:self options:nil][0];
    UIWindow *window=self.view.window;
    vvv.frame=window.bounds;
    [window addSubview:vvv];
    [vvv showWithCompletion:nil];

}

- (void)authManagerDidSendValidationPhone:(LWAuthManager *)manager {
    // copy data to model
    [self setLoading:NO];
    [self.view makeToast:@"SMS sent" duration:2 position:[NSValue valueWithCGPoint:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height-keyboardHeight-30)]];

}


- (void)authManagerDidCheckValidationPhone:(LWAuthManager *)manager passed:(BOOL)passed {
    if (passed) {
        [[LWAuthManager instance] requestDocumentsToUpload];
    }
    else {
        [self setLoading:NO];
        self.titleLabel.text = [NSString stringWithFormat:Localize(@"register.phone.error"), self.phone];
    }
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self setLoading:NO];
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

- (void)authManager:(LWAuthManager *)manager didCheckDocumentsStatus:(LWDocumentsStatus *)status {
    [self setLoading:NO];
    [((LWAuthNavigationController *)self.navigationController) navigateWithDocumentStatus:status hideBackButton:YES];
}

@end
