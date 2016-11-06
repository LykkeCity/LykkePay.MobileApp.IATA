//
//  LWRegisterBasePresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 20.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWRegisterBasePresenter.h"
#import "LWAuthNavigationController.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "LWDeviceInfo.h"


@interface LWRegisterBasePresenter () <LWTextFieldDelegate> {
    LWTextField *textField;
}

@property (weak, nonatomic) IBOutlet TKContainer *textContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end


@implementation LWRegisterBasePresenter


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.registrationInfo = [LWRegistrationData new];
    self.registrationInfo.clientInfo = [[LWDeviceInfo instance] clientInfo];
    
    self.title = Localize(@"title.register");

    textField = [LWTextField createTextFieldForContainer:self.textContainer
                                         withPlaceholder:self.fieldPlaceholder];
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.delegate = self;
    [self configureTextField:textField];
    
    [textField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // check button state
    [LWValidator setButton:self.nextButton enabled:[self canProceed]];

    self.observeKeyboardEvents = YES;
}

- (IBAction)nextClicked:(id)sender {
    [self proceedToNextStep];
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


#pragma mark - Navigation

- (void)proceedToNextStep {
    // copy data to model
    [self prepareNextStepData:textField.text];
    
    [((LWAuthNavigationController *)self.navigationController)
     navigateToStep:[self nextStep]
     preparationBlock:^(LWAuthStepPresenter *presenter) {
         LWRegisterBasePresenter *nextPresenter = (LWRegisterBasePresenter *)presenter;
         nextPresenter.registrationInfo = [self.registrationInfo copy];
     }];
}

- (void)prepareNextStepData:(NSString *)input {
    // override if necessary
}


#pragma mark - Utils

- (BOOL)validateInput:(NSString *)input {
    return NO;
}

- (void)configureTextField:(LWTextField *)textField {
    // override if necessary
}

- (NSString *)textFieldString {
    return textField.text;
}


#pragma mark - Properties

- (NSString *)fieldPlaceholder {
    return @"";
}

- (LWAuthStep)nextStep {
    return LWAuthStepEntryPoint;
}

- (BOOL)canProceed {
    return textField.isValid;
}


#pragma mark - LWTextFieldDelegate

- (void)textFieldDidChangeValue:(LWTextField *)textFieldInput {
    if (!self.isVisible) { // prevent from being processed if controller is not presented
        return;
    }
    textField.valid = [self validateInput:textField.text];
    // check button state
    [LWValidator setButton:self.nextButton enabled:self.canProceed];
}

@end
