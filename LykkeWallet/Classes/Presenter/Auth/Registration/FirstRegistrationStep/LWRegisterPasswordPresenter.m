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
    
    LWTextField *passwordConfirmTextField;
    
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet TKContainer *passwordConfirm;

@end


@implementation LWRegisterPasswordPresenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    passwordConfirmTextField = [LWTextField createTextFieldForContainer:self.passwordConfirm
                                         withPlaceholder:@"Confirm your password"];
    passwordConfirmTextField.keyboardType = UIKeyboardTypeDefault;
    passwordConfirmTextField.delegate = self;

}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}


- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
    
    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
    {
//        [super observeKeyboardWillShowNotification:notification];
        return;
    }
    
        self.scrollView.contentOffset=CGPointMake(0, 120);
        self.scrollView.scrollEnabled=NO;
    
}

- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
    {
        [super observeKeyboardWillShowNotification:notification];
        return;
    }
    self.scrollView.contentOffset=CGPointMake(0, 0);

    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollEnabled=YES;
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
    
    BOOL flag1=[LWValidator validatePassword:input];
    BOOL flag2=[lw]
    
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
