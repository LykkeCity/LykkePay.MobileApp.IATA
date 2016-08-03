//
//  LWRegisterPasswordPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 20.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWRegisterPasswordPresenter.h"
#import "LWAuthNavigationController.h"
#import "LWRegisterCameraPresenter.h"
#import "LWPersonalDataModel.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "UIViewController+Loading.h"




@interface LWRegisterPasswordPresenter () {
    
    LWTextField *passwordConfirmTextField;
    LWTextField *passwordTextField;
    
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet TKContainer *passwordConfirm;

@end


@implementation LWRegisterPasswordPresenter

- (void)viewDidLoad {
    [super viewDidLoad];

    passwordConfirmTextField = [LWTextField createTextFieldForContainer:self.passwordConfirm
                                         withPlaceholder:@"Confirm your password"];
//    passwordConfirmTextField.keyboardType = UIKeyboardTypeDefault;
    passwordConfirmTextField.delegate = self;
    passwordConfirmTextField.secure=YES;

    

}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

//- (void)proceedToNextStep {
//    [self setLoading:YES];
//    self.registrationInfo.password=passwordTextField.text;
//    
//}



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
//        [super observeKeyboardWillShowNotification:notification];
        return;
    }
    self.scrollView.contentOffset=CGPointMake(0, 0);

    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollEnabled=YES;
}

#pragma mark - LWRegisterBasePresenter

- (LWAuthStep)nextStep {
    return LWAuthStepRegisterHint;
}

- (void)prepareNextStepData:(NSString *)input {
    self.registrationInfo.password = input;
}

- (NSString *)fieldPlaceholder {
    return Localize(@"register.password");
}

- (BOOL)validateInput:(NSString *)input {
    
    BOOL flag1=[LWValidator validatePassword:passwordTextField.text];
    passwordTextField.valid=flag1;
    BOOL flag2=[passwordTextField.text isEqualToString:passwordConfirmTextField.text] && flag1;
    passwordConfirmTextField.valid=flag2;
    
    
    return flag1 && flag2;
}

- (void)configureTextField:(LWTextField *)textField {
    textField.secure = YES;
    textField.keyboardType=UIKeyboardTypeASCIICapable;
    passwordTextField=textField;
}


#pragma mark - LWAuthStepPresenter

- (LWAuthStep)stepId {
    return LWAuthStepRegisterPassword;
}


@end
