//
//  LWRegisterPasswordPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 20.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWRegisterPasswordPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWTextField.h"
#import "LWValidator.h"


@interface LWRegisterPasswordPresenter () {
    
}

@end


@implementation LWRegisterPasswordPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - LWRegisterBasePresenter

- (LWAuthStep)nextStep {
    return LWAuthStepRegisterConfirmPassword;
}

- (void)prepareNextStepData:(NSString *)input {
    self.registrationInfo.password = input;
}

- (NSString *)fieldPlaceholder {
    return Localize(@"register.password");
}

- (BOOL)validateInput:(NSString *)input {
    return [LWValidator validatePassword:input];
}

- (void)configureTextField:(LWTextField *)textField {
    textField.secure = YES;
}


#pragma mark - LWAuthStepPresenter

- (LWAuthStep)stepId {
    return LWAuthStepRegisterPassword;
}

@end
