//
//  LWKYCInvalidDocumentsPresenter.m
//  LykkeWallet
//
//  Created by Георгий Малюков on 15.12.15.
//  Copyright © 2015 Lykkex. All rights reserved.
//

#import "LWKYCInvalidDocumentsPresenter.h"
#import "LWRegisterCameraPresenter.h"
#import "LWRegistrationData.h"
#import "LWPersonalDataModel.h"
#import "LWKeychainManager.h"
#import "UIViewController+Loading.h"
#import "TKButton.h"
#import "LWConstants.h"


@interface LWKYCInvalidDocumentsPresenter () {
    LWAuthStep nextStep;
}

@property (weak, nonatomic) IBOutlet UILabel  *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel  *textLabel;
@property (weak, nonatomic) IBOutlet TKButton *okButton;


#pragma mark - Actions

- (IBAction)okButtonClick:(id)sender;

@end


@implementation LWKYCInvalidDocumentsPresenter


#pragma mark - LWAuthStepPresenter

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.okButton setTitleFont:[UIFont fontWithName:kFontSemibold size:kButtonFontSize]];
    [self.okButton setTitleColor:[UIColor colorWithHexString:kMainDarkElementsColor] forState:UIControlStateNormal];
    
    [self setLoading:YES];

    [[LWAuthManager instance] requestPersonalData];
}

- (void)localize {
    self.headerLabel.text = Localize(@"register.kyc.invalidDocuments.header");
    self.textLabel.text = [NSString stringWithFormat:Localize(@"register.kyc.invalidDocuments"),
                           [LWKeychainManager instance].fullName];
    [self.okButton setTitle:[Localize(@"register.kyc.invalidDocuments.okButton") uppercaseString]
                   forState:UIControlStateNormal];
}

- (LWAuthStep)stepId {
    return LWAuthStepRegisterKYCInvalidDocuments;
}


#pragma mark - Actions

- (IBAction)okButtonClick:(id)sender {
    [((LWAuthNavigationController *)self.navigationController) navigateWithDocumentStatus:[LWAuthManager instance].documentsStatus hideBackButton:YES];
}


#pragma mark - LWAuthManagerDelegate

- (void)authManager:(LWAuthManager *)manager didReceivePersonalData:(LWPersonalDataModel *)data {
    if ([data isFullNameEmpty]) {
        [self setLoading:NO];
        LWAuthNavigationController *navigation = (LWAuthNavigationController *)self.navigationController;
        [navigation navigateToStep:LWAuthStepRegisterFullName
                  preparationBlock:^(LWAuthStepPresenter *presenter) {
                  }];
    }
    else if ([data isPhoneEmpty]) {
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
    [self setLoading:NO];

    nextStep = [LWAuthSteps getNextDocumentByStatus:status];
}

- (void)authManager:(LWAuthManager *)manager didFailWithReject:(NSDictionary *)reject context:(GDXRESTContext *)context {
    
    if (reject) {
        [self showReject:reject response:context.task.response];
    }
    else {
        // some server error? Then just repeat request after some delay
        const NSInteger repeatSeconds = 5;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(repeatSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[LWAuthManager instance] requestDocumentsToUpload];
        });
    }
}

@end
