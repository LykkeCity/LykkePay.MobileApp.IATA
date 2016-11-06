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


@interface LWRegisterPhoneConfirmPresenter () <LWTextFieldDelegate> {
    LWTextField *codeTextField;
}


#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet TKContainer *codeContainer;
@property (weak, nonatomic) IBOutlet TKButton    *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel     *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel     *infoLabel;

@end


@implementation LWRegisterPhoneConfirmPresenter


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localize(@"register.title");
    
    // init email field
    codeTextField = [LWTextField new];
    codeTextField.delegate = self;
    codeTextField.keyboardType = UIKeyboardTypeDefault;
    codeTextField.placeholder = Localize(@"register.phone.code.placeholder");
    codeTextField.viewMode = UITextFieldViewModeNever;
    [self.codeContainer attach:codeTextField];
    
#ifdef PROJECT_IATA
#else
    [self.confirmButton setGrayPalette];
#endif
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoClicked:)];
    [self.infoLabel setUserInteractionEnabled:YES];
    [self.infoLabel addGestureRecognizer:gesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateButtonStatus];
}

- (void)localize {
    self.infoLabel.text = Localize(@"register.sms.help.info");
    self.statusLabel.text = [NSString stringWithFormat:Localize(@"register.phone.sent"), self.phone];
    
    
    [self.confirmButton setTitle:Localize(@"register.sms.confirm")
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
    
    [self updateButtonStatus];
}

#pragma mark - Outlets

- (IBAction)confirmClicked:(id)sender {
    if ([self canProceed]) {
        [self setLoading:YES];
        [[LWAuthManager instance] requestVerificationPhone:self.phone forCode:codeTextField.text];
    }
}

- (void)infoClicked:(id)sender {
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

- (void)updateButtonStatus {
    // check button state
    [LWValidator setButton:self.confirmButton enabled:[self canProceed]];
}


#pragma mark - LWAuthManagerDelegate

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
    [self showReject:reject response:context.task.response code:context.error.code willNotify:YES];
}

- (void)authManager:(LWAuthManager *)manager didCheckDocumentsStatus:(LWDocumentsStatus *)status {
    [self setLoading:NO];
    [((LWAuthNavigationController *)self.navigationController) navigateWithDocumentStatus:status hideBackButton:YES];
}

@end
