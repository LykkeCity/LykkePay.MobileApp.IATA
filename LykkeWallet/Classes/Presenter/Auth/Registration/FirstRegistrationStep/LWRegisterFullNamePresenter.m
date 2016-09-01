//
//  LWRegisterFNPresenter.m
//  LykkeWallet
//
//  Created by Alexander Pukhov on 20.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWRegisterFullNamePresenter.h"
#import "LWAuthNavigationController.h"
#import "LWPersonalDataModel.h"
#import "LWTextField.h"
#import "LWValidator.h"
#import "UIViewController+Loading.h"


@interface LWRegisterFullNamePresenter ()  {
    
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end


@implementation LWRegisterFullNamePresenter


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
}

//- (void)observeKeyboardWillShowNotification:(NSNotification *)notification {
//    
//    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
//    {
//        [super observeKeyboardWillShowNotification:notification];
//        return;
//    }
//    
//    self.scrollView.contentOffset=CGPointMake(0, 120);
//    self.scrollView.scrollEnabled=NO;
//    
//}
//
//- (void)observeKeyboardWillHideNotification:(NSNotification *)notification {
//    if([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad)
//    {
//        [super observeKeyboardWillShowNotification:notification];
//        return;
//    }
//    self.scrollView.contentOffset=CGPointMake(0, 0);
//    
//    self.scrollView.contentInset = UIEdgeInsetsZero;
//    self.scrollView.scrollEnabled=YES;
//}



#pragma mark - LWRegisterBasePresenter


- (void)proceedToNextStep {
    NSString *fullName = [self textFieldString];
    if (![fullName isEqualToString:@""]) {
        [self setLoading:YES];
        [[LWAuthManager instance] requestSetFullName:fullName];
    }
}

- (void)prepareNextStepData:(NSString *)input {
    self.registrationInfo.fullName = input;
}

- (BOOL)validateInput:(NSString *)input {
    return [LWValidator validateFullName:input];
}

- (void)configureTextField:(LWTextField *)textField {
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
}

- (NSString *)fieldPlaceholder {
    return Localize(@"register.fullName");
}


#pragma mark - LWAuthStepPresenter

- (LWAuthStep)nextStep {
    return LWAuthStepRegisterPhone;
}

- (LWAuthStep)stepId {
    return LWAuthStepRegisterFullName;
}


#pragma mark - LWAuthManagerDelegate

- (void)authManagerDidSetFullName:(LWAuthManager *)manager {
    [[LWAuthManager instance] requestPersonalData];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    [self showReject:reject response:context.task.response];
}

- (void)authManager:(LWAuthManager *)manager didReceivePersonalData:(LWPersonalDataModel *)data {
    if ([data isPhoneEmpty]) {
        [self setLoading:NO];
        LWAuthNavigationController *navigation = (LWAuthNavigationController *)self.navigationController;
        [navigation navigateToStep:LWAuthStepRegisterPhone
                  preparationBlock:^(LWAuthStepPresenter *presenter) {
                  }];
    }
    else {
        [[LWAuthManager instance] requestDocumentsToUpload];
    }
}

- (void)authManager:(LWAuthManager *)manager didCheckDocumentsStatus:(LWDocumentsStatus *)status {
    [((LWAuthNavigationController *)self.navigationController) navigateWithDocumentStatus:status hideBackButton:YES];
}

@end
