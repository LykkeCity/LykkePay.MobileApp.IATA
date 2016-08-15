//
//  LWSMSCodeStepPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 03.05.16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWSMSCodeStepPresenter.h"
#import "LWRegisterBasePresenter.h"
#import "LWAuthNavigationController.h"
#import "LWAuthManager.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "LWConstants.h"
#import "TKButton.h"
#import "UIViewController+Loading.h"
#import "UIView+Toast.h"
#import "LWGenerateKeyPresenter.h"


@interface LWSMSCodeStepPresenter ()<LWTextFieldDelegate> {
    LWTextField *codeTextField;
    CGFloat keyboardHeight;
}

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet TKContainer *codeContainer;
@property (weak, nonatomic) IBOutlet TKButton    *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel     *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton    *pasteButton;

@end


@implementation LWSMSCodeStepPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    keyboardHeight=0;
    
    
    // init email field
    codeTextField = [LWTextField new];
    codeTextField.delegate = self;
    codeTextField.keyboardType = UIKeyboardTypeDefault;
    codeTextField.placeholder = Localize(@"register.sms.code.placeholder");

    codeTextField.viewMode = UITextFieldViewModeNever;
    [self.codeContainer attach:codeTextField];
    
    [self.codeContainer bringSubviewToFront:self.pasteButton];
    
#ifdef PROJECT_IATA
#else
    [self.confirmButton setGrayPalette];
#endif
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoClicked:)];
    [self.infoLabel setUserInteractionEnabled:YES];
    [self.infoLabel addGestureRecognizer:gesture];
    
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        CGRect rect=self.view.frame;
        rect.origin.y=0;
        self.view.frame=rect;
    }

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updatePasteButtonStatus];

    [self setLoading:YES];
    [[LWAuthManager instance] requestVerificationEmail:self.email];
//    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        self.observeKeyboardEvents=YES;
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = Localize(@"register.title");
    
    
    
//    LWGenerateKeyPresenter *presenter=[[LWGenerateKeyPresenter alloc] init]; //Testing
//    [self.navigationController pushViewController:presenter animated:YES];
}

- (void)localize {
    self.infoLabel.text = Localize(@"register.sms.help.info");
    self.titleLabel.text = [NSString stringWithFormat:Localize(@"register.sms.title"), self.email];

    
    [self.confirmButton setTitle:Localize(@"register.sms.confirm")
                        forState:UIControlStateNormal];
    
    [self.pasteButton setTitle:Localize(@"register.sms.code.paste")
                      forState:UIControlStateNormal];
}

- (void)colorize {
    UIColor *color = [UIColor colorWithHexString:kMainElementsColor];
    [self.infoLabel setTextColor:color];
}

#pragma mark - LWTextFieldDelegate

- (void)textFieldDidChangeValue:(LWTextField *)textField {
    // prevent from being processed if controller is not presented
    if (!self.isVisible) {
        return;
    }
    
    [self updatePasteButtonStatus];
}

#pragma mark - Outlets

- (IBAction)confirmClicked:(id)sender {
    if (!(codeTextField.text == nil || codeTextField.text.length <= 0)) {
        [self setLoading:YES];
        [[LWAuthManager instance] requestVerificationEmail:self.email forCode:codeTextField.text];
    }
}

- (IBAction)pasteClicked:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    codeTextField.text = [pasteboard string];
    
    [self updatePasteButtonStatus];
}

- (void)infoClicked:(id)sender {
    [self setLoading:YES];
    [[LWAuthManager instance] requestVerificationEmail:self.email];



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

- (void)updatePasteButtonStatus {
    // check button state
    [LWValidator setButton:self.confirmButton enabled:[self canProceed]];
    self.pasteButton.hidden = [self canProceed];
}

- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
    CGRect const frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardHeight=frame.size.height;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad && ([UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationLandscapeRight))
    {
        CGRect rect=self.view.frame;
        rect.origin.y=-80;
        self.view.frame=rect;
    }
    
    [self animateConstraintChanges];
}

- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
    
    keyboardHeight=0;
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        CGRect rect=self.view.frame;
        rect.origin.y=self.navigationController.navigationBar.bounds.size.height+20;
        self.view.frame=rect;
    }
    
    
    [self animateConstraintChanges];
}




#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidSendValidationEmail:(LWAuthManager *)manager {
    [self setLoading:NO];
    self.titleLabel.text = [NSString stringWithFormat:Localize(@"register.sms.title"), self.email];
    [self.view makeToast:@"Code sent" duration:2 position:[NSValue valueWithCGPoint:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height-keyboardHeight-30)]];

}

- (void)authManagerDidCheckValidationEmail:(LWAuthManager *)manager passed:(BOOL)passed {
    [self setLoading:NO];
    
    if (passed) {
        LWAuthNavigationController *nav = (LWAuthNavigationController *)self.navigationController;
        [nav navigateToStep:LWAuthStepRegisterPassword
           preparationBlock:^(LWAuthStepPresenter *presenter) {
               ((LWRegisterBasePresenter *)presenter).registrationInfo.email = self.email;
           }];
    }
    else {
        self.titleLabel.text = [NSString stringWithFormat:Localize(@"register.sms.error"), self.email];
    }
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

@end
