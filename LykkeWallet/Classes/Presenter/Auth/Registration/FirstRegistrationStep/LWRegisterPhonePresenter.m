//
//  LWRegisterPhonePresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 20.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWRegisterPhonePresenter.h"
#import "LWRegisterPhoneConfirmPresenter.h"
#import "LWCountrySelectorPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "UIViewController+Loading.h"


@interface LWRegisterPhonePresenter () <UITextFieldDelegate, LWCountrySelectorPresenterDelegate> {
}

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end


@implementation LWRegisterPhonePresenter


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = Localize(@"title.register");
    [self.nextButton setTitle:Localize(@"register.phone.send")
                     forState:UIControlStateNormal];
    
    self.codeTextField.keyboardType = UIKeyboardTypePhonePad;
    self.codeTextField.delegate = self;
    self.codeTextField.text = @"+";
    
    self.numberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.numberTextField.delegate = self;
    self.numberTextField.placeholder = Localize(@"register.phone.placeholder");
    
    [self.codeTextField addTarget:self
                           action:@selector(textFieldDidChangeValue:)
                 forControlEvents:UIControlEventEditingChanged];
    
    [self.numberTextField addTarget:self
                             action:@selector(textFieldDidChangeValue:)
                   forControlEvents:UIControlEventEditingChanged];

    [self.codeTextField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [LWValidator setButton:self.nextButton enabled:[self canProceed]];
    
    self.observeKeyboardEvents = YES;
}

- (IBAction)nextClicked:(id)sender {
    if ([self canProceed]) {
        NSString *phone = [self phoneNumber];
        [self setLoading:YES];
        [[LWAuthManager instance] requestVerificationPhone:phone];
    }
}

- (IBAction)countryClicked:(id)sender {
    LWCountrySelectorPresenter *presenter = [LWCountrySelectorPresenter new];
    presenter.delegate = self;
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:presenter];

    [self.navigationController presentViewController:navigation
                                            animated:YES
                                          completion:nil];
}

#pragma mark - Keyboard

- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    const CGFloat bottomMargin = 20;
    CGFloat bottomX = (self.scrollView.frame.origin.y
                       + self.nextButton.frame.origin.y
                       + self.nextButton.frame.size.height
                       + bottomMargin);
    if (bottomX > rect.size.height) {
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, bottomX - rect.size.height, 0);
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentInset.bottom);
    }
}

- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
    self.scrollView.contentInset = UIEdgeInsetsZero;
}


#pragma mark - Properties

- (NSString *)fieldPlaceholder {
    return @"";
}

- (LWAuthStep)nextStep {
    return LWAuthStepRegisterPhoneConfirm;
}

- (BOOL)canProceed {
    return (self.codeTextField.text.length > 0 &&
            self.numberTextField.text.length > 0);
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidChangeValue:(UITextField *)textFieldInput {
    // prevent from being processed if controller is not presented
    if (!self.isVisible) {
        return;
    }

    [LWValidator setButton:self.nextButton enabled:self.canProceed];
}


#pragma mark - LWCountrySelectorPresenterDelegate

- (void)countrySelected:(NSString *)name code:(NSString *)code prefix:(NSString *)prefix {
    self.codeTextField.text = prefix;
    
    [LWValidator setButton:self.nextButton enabled:self.canProceed];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response];
}

- (void)authManagerDidSendValidationPhone:(LWAuthManager *)manager {
    // copy data to model
    [self setLoading:NO];
    LWAuthNavigationController *controller = (LWAuthNavigationController *)self.navigationController;
    [controller navigateToStep:[self nextStep]
              preparationBlock:^(LWAuthStepPresenter *presenter) {
                  LWRegisterPhoneConfirmPresenter *nextPresenter = (LWRegisterPhoneConfirmPresenter *)presenter;
                  nextPresenter.phone = [self phoneNumber];
              }];
}

- (NSString *)phoneNumber {
    NSString *phone = [NSString stringWithFormat:@"%@%@", self.codeTextField.text, self.numberTextField.text];
    phone = [phone stringByReplacingOccurrencesOfString:@"+" withString:@""];
    return phone;
}

@end
